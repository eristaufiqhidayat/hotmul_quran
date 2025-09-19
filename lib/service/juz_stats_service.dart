// lib/services/juz_stats_service.dart
import 'dart:convert';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:http/http.dart' as http;
import 'package:hotmul_quran/model/juz_stats_model.dart';

class JuzStatsService {
  static const String baseUrl = "${GlobalConst.url}/api/v1";

  Future<JuzStatsResponse> getJuzStatsWithStatus({
    String? groupId,
    int? minJuz,
    int? maxJuz,
  }) async {
    try {
      final token = await getValidAccessToken();
      final Uri uri = Uri.parse('$baseUrl/juz-stats/with-status').replace(
        queryParameters: {
          if (groupId != null) 'group_id': groupId,
          if (minJuz != null) 'min_juz': minJuz.toString(),
          if (maxJuz != null) 'max_juz': maxJuz.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return JuzStatsResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load juz stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching juz stats: $e');
    }
  }

  Future<JuzStats> getJuzStatsByAnggota(String anggotaId) async {
    try {
      final token = await getValidAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/juz-stats/anggota/$anggotaId'),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          return JuzStats.fromJson(data['data']);
        } else {
          throw Exception('Data anggota tidak ditemukan');
        }
      } else {
        throw Exception('Failed to load anggota stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching anggota stats: $e');
    }
  }

  Future<JuzStatsResponse> getDetailedJuzStats({String? groupId}) async {
    try {
      final token = await getValidAccessToken();
      final Uri uri = Uri.parse(
        '$baseUrl/juz-stats/detailed',
      ).replace(queryParameters: {if (groupId != null) 'group_id': groupId});

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return JuzStatsResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load detailed stats: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching detailed stats: $e');
    }
  }

  Future<Map<String, dynamic>> getJuzStatsSummary() async {
    try {
      final token = await getValidAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/juz-stats/summary'),
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Pastikan struktur data sesuai yang diharapkan
        if (responseData['data'] is Map<String, dynamic>) {
          return responseData;
        } else {
          throw Exception('Format data summary tidak valid');
        }
      } else {
        throw Exception('Failed to load summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching summary: $e');
    }
  }
  // Di services/juz_stats_service.dart, perbaikan method getJuzStatsSummary()
}
