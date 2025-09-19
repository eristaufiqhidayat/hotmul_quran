// lib/services/khotmul_service.dart
import 'dart:convert';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:http/http.dart' as http;
import 'package:hotmul_quran/model/khotmul_stats.dart';

class KhotmulService {
  static const String baseUrl = "${GlobalConst.url}/api/v1";

  Future<KhotmulResponse> getKhotmulStats() async {
    try {
      final token = await getValidAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/khotmul/stats'),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return KhotmulResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching khotmul stats: $e');
    }
  }

  Future<KhotmulResponse> getKhotmulStatsByGroup(String groupId) async {
    final token = await getValidAccessToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/khotmul/stats/group/$groupId'),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return KhotmulResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching group stats: $e');
    }
  }
}
