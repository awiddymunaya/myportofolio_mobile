import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Menyimpan token autentikasi sesi saat ini di memori.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    try {
      await _apiClient.logout(token: current);
    } on ApiException catch (error) {
      // Misalnya token sudah dicabut di server (401). Tetap keluar di aplikasi.
      debugPrint('Logout di server gagal: $error');
    } finally {
      // Token selalu dihapus dari aplikasi, walaupun request ke server gagal.
      _token = null;
      notifyListeners();
    }
  }
}
