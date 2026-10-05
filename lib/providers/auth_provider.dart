import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';

class AuthProvider with ChangeNotifier {
  bool _loading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _role;

  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';

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
        "${GlobalConst.apiV1}/login",
        body: {"email": email.trim(), "password": password},
      );

      final result = json.decode(response.body);

      if (response.statusCode != 200) {
        _setError(
          (result is Map ? result['message'] : null)?.toString() ??
              "Login gagal (${response.statusCode})",
        );
        _setLoading(false);
        return false;
      }

      if (result['access_token'] == null) {
        _setError("Token tidak ditemukan");
        _setLoading(false);
        return false;
      }

      final user = Map<String, dynamic>.from(result['user'] ?? {});
      _role = user['role']?.toString() ?? 'member';

      // Sanctum: token berupa string "id|plain", bukan JWT.
      await saveToken(
        token: result['access_token'].toString(),
        name: user['name']?.toString() ?? '',
        email: user['email']?.toString() ?? '',
        role: _role!,
        userId: user['id']?.toString() ?? '',
        groupId: user['group_id']?.toString() ?? '',
        anggotaId: user['anggota_id']?.toString() ?? '',
        daurahId: user['daurah_id']?.toString() ?? '',
        juz: user['juz']?.toString() ?? '',
      );

      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint("Login error: $e");
      _setError("Tidak dapat terhubung ke server");
      _setLoading(false);
      return false;
    }
  }

  /// Token Sanctum tidak memiliki masa berlaku di sisi klien, jadi cukup
  /// cek keberadaannya. Token yang dicabut server akan ditangani
  /// [ApiClient] (respon 401 → kembali ke halaman login).
  Future<void> checkAuth() async {
    final token = await getToken();
    _isAuthenticated = token != null && token.isNotEmpty;
    _role = _isAuthenticated ? await getRole() : null;
    notifyListeners();
  }

  Future<void> logout() async {
    await clearToken();
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }
}
