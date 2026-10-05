import 'dart:convert';
import 'package:hotmul_quran/main.dart';
import 'package:http/http.dart' as http;
import 'package:hotmul_quran/service/token_services.dart';

/// Error dari API dengan pesan yang bisa ditampilkan ke user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static const Duration timeout = Duration(seconds: 30);

  /// GET
  static Future<http.Response> get(String url) async {
    final token = await getToken();
    //print(token);
    final response = await http
        .get(Uri.parse(url), headers: _headers(token))
        .timeout(timeout);

    await _handleUnauthorized(response);
    return response;
  }

  /// POST
  static Future<http.Response> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();

    final response = await http
        .post(
          Uri.parse(url),
          headers: _headers(token),
          body: body != null ? jsonEncode(body) : null, // 🔥 FIX UTAMA
        )
        .timeout(timeout);

    await _handleUnauthorized(response);
    return response;
  }

  /// PUT
  static Future<http.Response> put(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();

    final response = await http
        .put(
          Uri.parse(url),
          headers: _headers(token),
          body: body != null ? jsonEncode(body) : null, // 🔥 FIX
        )
        .timeout(timeout);
    //print("PUT Response: ${response.body}");
    await _handleUnauthorized(response);
    return response;
  }

  /// DELETE
  static Future<http.Response> delete(String url) async {
    final token = await getToken();

    final response = await http
        .delete(Uri.parse(url), headers: _headers(token))
        .timeout(timeout);

    await _handleUnauthorized(response);
    return response;
  }

  /// HEADER DEFAULT
  static Map<String, String> _headers(String? token) {
    return {
      "Accept": "application/json",
      "Content-Type": "application/json", // tetap JSON
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// AUTO HANDLE TOKEN EXPIRED
  static Future<void> _handleUnauthorized(http.Response response) async {
    try {
      final body = json.decode(response.body);

      if (response.statusCode == 401 ||
          (body is Map &&
              body['message'].toString().toLowerCase().contains(
                'unauthenticated',
              ))) {
        await clearToken();

        /// 🔥 REDIRECT KE LOGIN (DI SINI TEMPATNYA)
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (_) {
      if (response.statusCode == 401) {
        await clearToken();

        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  /// RESPONSE PARSER
  static dynamic decode(http.Response response) {
    return jsonDecode(response.body);
  }

  /// Ambil pesan error dari respon Laravel (`message` / `errors`).
  static String errorMessage(http.Response response, {String? fallback}) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        if (body['message'] != null) return body['message'].toString();
      }
    } catch (_) {}
    return fallback ?? 'Terjadi kesalahan (${response.statusCode})';
  }
}
