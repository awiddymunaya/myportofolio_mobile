import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Tiruan sederhana backend Django untuk test, memakai MockClient
/// dari package:http/testing.dart (tidak ada request jaringan sungguhan).
class FakeBackend {
  FakeBackend({List<Map<String, dynamic>>? experiences})
    : experiences = experiences ?? [sampleExperience()];

  static const ownerToken = 'owner-token';
  static const visitorToken = 'visitor-token';

  final List<Map<String, dynamic>> experiences;

  /// Status paksa untuk GET daftar (misalnya 500 untuk menguji error).
  int? listStatus;

  /// true = token yang dikirim dianggap sudah dicabut (401).
  bool tokenExpired = false;

  int listCalls = 0;
  int logoutCalls = 0;
  final List<Map<String, dynamic>> createdBodies = [];
  final List<String?> createAuthHeaders = [];

  static const _labels = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  static Map<String, dynamic> sampleExperience({
    String title = 'Asisten Dosen PBP',
    String thumbnail = '/static/img/asdos.jpg',
  }) => {
    'id': '7d1f0c8e-0000-4000-8000-000000000001',
    'title': title,
    'description': 'Membantu praktikum Pemrograman Berbasis Platform',
    'category': 'part-time',
    'category_display': 'Part-Time',
    'thumbnail': thumbnail,
    'logo_url': null,
    'started_at': '2026-02-01',
    'ended_at': null,
    'is_ongoing': true,
    'star_count': 3,
    'is_starred': false,
    'starred_by_names': 'a, b, c',
  };

  late final MockClient client = MockClient(_handle);

  ApiClient get apiClient => ApiClient(client: client, baseUrl: 'http://api');

  http.Response _json(Object body, int status) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );

  Future<http.Response> _handle(http.Request request) async {
    final path = request.url.path;
    final auth = request.headers['Authorization'];
    final validToken =
        !tokenExpired &&
        (auth == 'Token $ownerToken' || auth == 'Token $visitorToken');

    if (path == '/api/v1/auth/token/' && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'owner' && body['password'] == 'secret') {
        return _json({'token': ownerToken}, 200);
      }
      if (body['username'] == 'visitor' && body['password'] == 'secret') {
        return _json({'token': visitorToken}, 200);
      }
      return _json({
        'non_field_errors': ['Unable to log in with provided credentials.'],
      }, 400);
    }

    if (path == '/api/v1/auth/logout/' && request.method == 'POST') {
      logoutCalls++;
      if (!validToken) return _json({'detail': 'Invalid token.'}, 401);
      return http.Response('', 204);
    }

    if (path == '/api/v1/experiences/' && request.method == 'GET') {
      listCalls++;
      if (listStatus != null) return http.Response('Server Error', listStatus!);
      return _json(experiences, 200);
    }

    if (path == '/api/v1/experiences/' && request.method == 'POST') {
      createAuthHeaders.add(auth);
      if (!validToken) return _json({'detail': 'Invalid token.'}, 401);
      if (auth == 'Token $visitorToken') {
        return _json({'detail': 'Akses ditolak.'}, 403);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      createdBodies.add(body);
      final created = {
        ...body,
        'id': '7d1f0c8e-0000-4000-8000-00000000000${experiences.length + 1}',
        'category_display': _labels[body['category']] ?? body['category'],
        'is_ongoing': body['ended_at'] == null,
        'star_count': 0,
        'is_starred': false,
        'starred_by_names': '',
      };
      experiences.add(created);
      return _json(created, 201);
    }

    return http.Response('Not Found', 404);
  }
}

/// Menjalankan aplikasi dengan backend tiruan.
Future<void> pumpApp(WidgetTester tester, FakeBackend backend) async {
  await tester.pumpWidget(MyApp(apiClient: backend.apiClient));
}

/// Mengisi halaman Login lalu menekan tombol Login.
Future<void> submitLogin(
  WidgetTester tester, {
  String username = 'owner',
  String password = 'secret',
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Username'),
    username,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

/// Font bawaan flutter test (Ahem) jauh lebih lebar dari font asli,
/// sehingga teks DrawerHeader dianggap overflow. Abaikan khusus error itu.
void ignoreOverflowErrors() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (!details.exceptionAsString().contains('overflowed')) {
      originalOnError?.call(details);
    }
  };
  addTearDown(() => FlutterError.onError = originalOnError);
}

/// Membuka drawer dari halaman yang sedang tampil.
Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

/// Menunggu SnackBar hilang supaya tidak menutupi tombol lain.
Future<void> waitSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
