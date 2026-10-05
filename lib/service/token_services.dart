// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/main.dart';
//import 'package:hotmul_quran/pages/homepage.dart';
import 'package:hotmul_quran/pages/login.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> _sessionKeys = [
  'access_token',
  'refresh_token',
  'name',
  'email',
  'role',
  'anggota_id',
  'group_id',
  'daurah_id',
  'user_id',
  'juz',
  // kunci lama: password dulu disimpan polos, sekarang selalu dihapus
  'password',
];

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  for (final key in _sessionKeys) {
    await prefs.remove(key);
  }
}

/// Simpan sesi login. Password tidak pernah disimpan di perangkat.
Future<void> saveToken({
  required String token,
  String refreshToken = '',
  required String name,
  required String email,
  required String role,
  required String userId,
  String groupId = '',
  String anggotaId = '',
  String daurahId = '',
  String juz = '',
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', token);
  await prefs.setString('refresh_token', refreshToken);
  await prefs.setString('name', name);
  await prefs.setString('email', email);
  await prefs.setString('username', email);
  await prefs.setString('role', role);
  await prefs.setString('user_id', userId);
  await prefs.setString('group_id', groupId);
  await prefs.setString('anggota_id', anggotaId);
  await prefs.setString('daurah_id', daurahId);
  await prefs.setString('juz', juz);
  await prefs.remove('password');
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token'); // null kalau belum ada
}

Future<String?> getJuz() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('juz'); // null kalau belum ada
}

/// Role user dari API: `admin` atau `member`.
Future<String?> getRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('role');
}

Future<bool> isAdmin() async => (await getRole()) == 'admin';

Future<String?> getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('username'); // null kalau belum ada
}

Future<String?> getUser_id() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id'); // null kalau belum ada
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
    print(payload);
    //final exp = 1000;
    if (exp == null) return true;

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

    final now = DateTime.now();
    // Duration remaining = expiry.difference(now);
    // print(remaining);
    return DateTime.now().isAfter(expiry);
  } catch (e) {
    return true;
  }
}

Future<String?> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("name");
}

Future<String?> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("email");
}

Future<String?> getAnggota_id() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("anggota_id");
}

Future<String?> getGroup_id() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("group_id");
}

Future<String?> getDaurah_id() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("daurah_id");
}

/// Dapatkan token (auto refresh jika perlu)
Future<String?> getValidAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString("access_token");

  //String? refreshToken = prefs.getString("refresh_token");
  //print("Access Token: $accessToken");

  // print("${GlobalConst.url}/api/v1/refresh");
  // print("Access Token: $accessToken");

  //if (accessToken == null) return null;

  //bool expired = await isTokenExpired(accessToken!);
  //print("Token expired: $expired");

  //if (expired) {
  // langsung pakai accessToken lama untuk refresh
  // final newToken = await refreshAccessToken(accessToken);

  // if (newToken != null) {
  //   await prefs.setString("access_token", newToken);
  //   return newToken;
  // } else {
  //   await logout();
  //   return null;
  // }
  //}
  return accessToken;
}

/// Refresh access token ke API Laravel
Future<String?> refreshAccessToken(String oldAccessToken) async {
  try {
    final response = await ApiClient.post("${GlobalConst.url}/api/v1/refresh");

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
  try {
    await ApiClient.post("${GlobalConst.apiV1}/logout");
  } catch (_) {
    // tetap hapus sesi lokal walau server tidak terjangkau
  }
  await clearToken();
  //misalnya arahkan ke halaman login

  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false,
  );
}
