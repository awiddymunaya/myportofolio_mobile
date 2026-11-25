import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/experience.dart';

/// Dilempar ketika API membalas dengan status di luar 2xx.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Klien HTTP untuk backend Django REST Framework MyPortfolio.
///
/// Header ditulis sebagai string biasa ('Accept', 'Authorization', ...)
/// dan bukan HttpHeaders dari dart:io, supaya tetap jalan di Flutter Web.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// Mengubah path gambar dari Django (misalnya `/static/img/a.jpg`)
  /// menjadi URL lengkap. URL http(s) dikembalikan apa adanya.
  String resolveImageUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseUrl${path.startsWith('/') ? '' : '/'}$path';
  }

  /// GET /api/v1/experiences/ (publik, tanpa login).
  Future<List<Experience>> getExperiences() async {
    final response = await _client.get(
      _uri('/api/v1/experiences/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return decoded
        .map((item) => Experience.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/v1/experiences/ dengan header `Authorization: Token <key>`.
  /// Hanya superuser (Pemilik) yang diizinkan Django.
  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/experiences/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(experience.toJson()),
    );
    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Experience.fromJson(decoded);
  }

  /// POST /api/v1/auth/token/: menukar username + password menjadi token.
  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  /// POST /api/v1/auth/logout/: mencabut token di server (204 No Content).
  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
