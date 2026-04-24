import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';

class AuthProvider with ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

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
      final response = await http.post(
        Uri.parse("${GlobalConst.url}/api/login"),
        headers: {"Accept": "application/json"},
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        final data = result['data'];
        final user = data['user'];

        await saveToken(
          data['token'],
          "",
          user['name'] ?? '',
          user['email'] ?? '',
          user['anggota_id']?.toString() ?? '',
          user['group_id']?.toString() ?? '',
          "",
          password,
          user['id']?.toString() ?? '',
          "",
        );

        _setLoading(false);
        return true;
      } else {
        _setError("Login gagal");
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await clearToken();
    notifyListeners();
  }
}
