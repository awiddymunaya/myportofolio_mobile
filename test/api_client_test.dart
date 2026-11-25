import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'fake_backend.dart';

void main() {
  group('Experience (json_serializable)', () {
    test(
      'fromJson membaca snake_case dan mengganti null dengan string kosong',
      () {
        final experience = Experience.fromJson(FakeBackend.sampleExperience());

        expect(experience.id, '7d1f0c8e-0000-4000-8000-000000000001');
        expect(experience.categoryLabel, 'Part-Time');
        expect(experience.logoUrl, '');
        expect(experience.startedAt, '2026-02-01');
        expect(experience.endedAt, isNull);
        expect(experience.isOngoing, isTrue);
        expect(experience.starCount, 3);
      },
    );

    test('toJson tidak mengirim id dan field read-only', () {
      const experience = Experience(
        id: 'abc',
        title: 'Staf Acara',
        description: 'Mengatur rundown',
        category: 'volunteer',
        startedAt: '2026-01-10',
        endedAt: '2026-02-10',
        categoryDisplay: 'Volunteer',
        starCount: 5,
      );

      expect(experience.toJson(), {
        'title': 'Staf Acara',
        'description': 'Mengatur rundown',
        'category': 'volunteer',
        'thumbnail': '',
        'logo_url': '',
        'started_at': '2026-01-10',
        'ended_at': '2026-02-10',
      });
    });

    test('period memotong datetime menjadi tanggal saja', () {
      const experience = Experience(
        title: 'a',
        description: 'b',
        startedAt: '2025-01-01',
        endedAt: '2025-06-30T00:00:00Z',
      );
      expect(experience.period, '2025-01-01 - 2025-06-30');
    });

    test('period untuk data lama tanpa tanggal mulai', () {
      const noDates = Experience(title: 'a', description: 'b');
      expect(noDates.period, 'Tanggal belum diisi');
      const onlyEnd = Experience(
        title: 'a',
        description: 'b',
        endedAt: '2024-12-31T00:00:00Z',
      );
      expect(onlyEnd.period, 'Sampai 2024-12-31');
    });
  });

  group('ApiClient', () {
    test('createExperience mengirim header Token dan body JSON', () async {
      late http.Request sent;
      final client = ApiClient(
        baseUrl: 'http://api',
        client: MockClient((request) async {
          sent = request;
          return http.Response(
            jsonEncode({
              ...jsonDecode(request.body) as Map<String, dynamic>,
              'id': 'baru',
            }),
            201,
          );
        }),
      );

      final created = await client.createExperience(
        const Experience(title: 'Judul', description: 'Deskripsi panjang'),
        token: 'abc123',
      );

      expect(sent.method, 'POST');
      expect(sent.url.toString(), 'http://api/api/v1/experiences/');
      expect(sent.headers['Authorization'], 'Token abc123');
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), isNot(contains('id')));
      expect(created.id, 'baru');
    });

    test('status di luar 2xx dilempar sebagai ApiException', () async {
      final client = ApiClient(
        baseUrl: 'http://api',
        client: MockClient((_) async => http.Response('{"detail":"x"}', 401)),
      );

      expect(
        () => client.getExperiences(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('resolveImageUrl melengkapi path relatif', () {
      final client = ApiClient(baseUrl: 'http://api');
      expect(
        client.resolveImageUrl('/static/a.jpg'),
        'http://api/static/a.jpg',
      );
      expect(
        client.resolveImageUrl('https://x.id/a.png'),
        'https://x.id/a.png',
      );
      expect(client.resolveImageUrl(''), '');
    });
  });

  group('AuthState', () {
    test('login menyimpan token, logout menghapusnya', () async {
      final backend = FakeBackend();
      final auth = AuthState(backend.apiClient);
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.login('owner', 'secret');
      expect(auth.isLoggedIn, isTrue);
      expect(auth.token, FakeBackend.ownerToken);

      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(backend.logoutCalls, 1);
      expect(notified, 2);
    });

    test('logout tetap menghapus token walaupun server menolak', () async {
      final backend = FakeBackend()..tokenExpired = true;
      final auth = AuthState(backend.apiClient, initialToken: 'lama');

      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
    });

    test('login gagal tidak menyimpan token', () async {
      final auth = AuthState(FakeBackend().apiClient);
      await expectLater(
        auth.login('owner', 'salah'),
        throwsA(isA<ApiException>()),
      );
      expect(auth.isLoggedIn, isFalse);
    });
  });
}
