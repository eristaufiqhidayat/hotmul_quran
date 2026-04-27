import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';

class AuthProvider with ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool _isAuthenticated = false;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiClient.post(
        "${GlobalConst.url}/api/v1/login",
        body: {"email": email, "password": password},
      );

      print("Login response: ${response.statusCode}");
      print(response.body);

      /// ❌ kalau bukan 200 → gagal
      if (response.statusCode != 200) {
        _setError("Login gagal (${response.statusCode})");
        _setLoading(false);
        return false;
      }

      final result = json.decode(response.body);

      /// ✅ VALIDASI TOKEN (INI KUNCI)
      if (result['access_token'] == null) {
        _setError("Token tidak ditemukan");
        _setLoading(false);
        return false;
      }
      print(result);

      /// ✅ SIMPAN TOKEN
      await saveToken(
        result['access_token'] ?? '',
        result['user']['refresh_token'] ?? '',
        result['user']['name'] ?? '',
        result['user']['email'] ?? '',
        result['user']['anggota_id']?.toString() ?? '',
        result['user']['role']?.toString() ?? '',
        result['user']['daurah_id']?.toString() ?? '',
        password,
        result['user']['id']?.toString() ?? '',
        result['user']['juz']?.toString() ?? '',
      );

      _setLoading(false);
      return true;
    } catch (e) {
      print("Login error: $e");
      _setError("Terjadi kesalahan");
      _setLoading(false);
      return false;
    }
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = json.decode(payload);

      final exp = data['exp'];
      if (exp == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return now > exp;
    } catch (e) {
      return true;
    }
  }

  Future<void> checkAuth() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      _isAuthenticated = false;
      notifyListeners();
      return;
    }

    final expired = _isTokenExpired(token);

    if (expired) {
      await clearToken();
      _isAuthenticated = false;
    } else {
      _isAuthenticated = true;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await clearToken();
    notifyListeners();
  }
}
