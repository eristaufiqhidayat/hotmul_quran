// services/api_service.dart
import 'dart:convert';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:http/http.dart' as http;
import 'package:hotmul_quran/model/daurah_graph_report.dart';

class ApiService {
  static const String baseUrl = 'https://hotmulquran.paud-arabika.com/api/v1';

  Future<List<DaurahData>> getDaurahData() async {
    final token = await getValidAccessToken();
    //print(baseUrl);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getDaurahData'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> daurahList = data['data'] ?? [];

          return daurahList.map((json) => DaurahData.fromJson(json)).toList();
        } else {
          throw Exception('API returned unsuccessful response');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
