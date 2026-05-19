import 'dart:convert';

import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';

class AssignmentRepo {
  final String baseUrl = "${GlobalConst.url}/api";

  /// =========================
  /// GET DATA
  /// =========================
  Future<Map<String, dynamic>?> getToday() async {
    try {
      final response = await ApiClient.get("$baseUrl/v1/khotmulPeriode");

      print("GET RESPONSE : ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("GET ERROR : $e");

      return null;
    }
  }

  Future<Map<String, dynamic>?> getPeriodeActive() async {
    try {
      final response = await ApiClient.get("$baseUrl/v1/khotmul-periode");

      print("GET RESPONSE periode active : ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("GET ERROR : $e");

      return null;
    }
  }

  Future<Map<String, dynamic>?> getPeriodeLast() async {
    try {
      final response = await ApiClient.get("$baseUrl/v1/khotmul-periode/last");

      print("GET RESPONSE periode active : ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("GET ERROR : $e");

      return null;
    }
  }

  /// =========================
  /// INSERT
  /// =========================
  Future<Map<String, dynamic>?> insert(Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.post(
        "$baseUrl/v1/khotmul-periode",
        body: body,
      );

      print("INSERT RESPONSE : ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("INSERT ERROR : $e");

      return null;
    }
  }

  /// =========================
  /// UPDATE
  /// =========================
  Future<Map<String, dynamic>?> update(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await ApiClient.put(
        "$baseUrl/v1/khotmul-periode/$id",
        body: body,
      );

      print("UPDATE RESPONSE : ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("UPDATE ERROR : $e");

      return null;
    }
  }

  /// =========================
  /// DELETE
  /// =========================
  Future<Map<String, dynamic>?> delete(int id) async {
    try {
      final response = await ApiClient.delete(
        "$baseUrl/v1/khotmul-periode/$id",
      );

      print("DELETE RESPONSE : ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("DELETE ERROR : $e");

      return null;
    }
  }
}
