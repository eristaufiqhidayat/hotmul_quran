import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/model/khotmul_stats.dart';

class KhotmulService {
  static const String baseUrl = "${GlobalConst.url}/api/v1";

  /// GLOBAL STATS
  Future<KhotmulResponse> getKhotmulStats() async {
    try {
      final response = await ApiClient.get('$baseUrl/khotmul/stats');

      if (response.statusCode == 200) {
        return KhotmulResponse.fromJson(ApiClient.decode(response));
      }

      throw Exception('Failed to load data: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching khotmul stats: $e');
    }
  }

  /// BY GROUP
  Future<KhotmulResponse> getKhotmulStatsByGroup(String groupId) async {
    try {
      final response = await ApiClient.get(
        '$baseUrl/khotmul/stats/group/$groupId',
      );

      if (response.statusCode == 200) {
        return KhotmulResponse.fromJson(ApiClient.decode(response));
      }

      throw Exception('Failed to load data: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching group stats: $e');
    }
  }
}
