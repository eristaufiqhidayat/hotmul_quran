import 'dart:convert';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/main.dart';
import 'package:hotmul_quran/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

Future<void> saveToken(String token, String refresh_token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', token);
  await prefs.setString('refresh_token', refresh_token);
  //print("refresh token disimpan: $refresh_token");
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token'); // null kalau belum ada
}

Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
}

Future<Map<String, dynamic>> _parseJwt(String token) async {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Token tidak valid');
  }

  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final decoded = utf8.decode(base64Url.decode(normalized));
  final payloadMap = json.decode(decoded);

  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('Payload token tidak valid');
  }

  return payloadMap;
}

/// Cek apakah token expired
Future<bool> isTokenExpired(String token) async {
  try {
    final payload = await _parseJwt(token);
    final exp = payload['exp'];
    //final exp = 1000;
    if (exp == null) return true;

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

    //final now = DateTime.now();
    //Duration remaining = expiry.difference(now);
    //print(remaining);
    return DateTime.now().isAfter(expiry);
  } catch (e) {
    return true;
  }
}

/// Dapatkan token (auto refresh jika perlu)
Future<String?> getValidAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString("access_token");
  //String? refreshToken = prefs.getString("refresh_token");
  //print("Access Token: $accessToken");
  //print("${GlobalConst.url}/api/v1/refresh");
  if (accessToken == null) return null;

  bool expired = await isTokenExpired(accessToken);

  if (expired) {
    // langsung pakai accessToken lama untuk refresh
    final newToken = await refreshAccessToken(accessToken);

    if (newToken != null) {
      await prefs.setString("access_token", newToken);
      return newToken;
    } else {
      await logout();
      return null;
    }
  }
  return accessToken;
}

/// Refresh access token ke API Laravel
Future<String?> refreshAccessToken(String oldAccessToken) async {
  try {
    final response = await http.post(
      Uri.parse("${GlobalConst.url}/api/v1/refresh"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $oldAccessToken",
      },
    );

    //print("Refresh response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    }
  } catch (e) {
    print("Refresh token gagal: $e");
  }
  return null;
}

/// Logout user
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("access_token");
  await prefs.remove("refresh_token");
  // misalnya arahkan ke halaman login
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false,
  );
}
