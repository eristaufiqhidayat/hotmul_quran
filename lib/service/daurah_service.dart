// services/api_service.dart
import 'dart:convert';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/model/daurah_graph_report.dart';
import 'package:hotmul_quran/model/daurah_model.dart';
import 'package:hotmul_quran/model/laporan_hapalan_model.dart';

class ApiService {
  static const String baseUrl = GlobalConst.url + '/api/v1';

  Future<List<DaurahData>> getDaurahData() async {
    //print(baseUrl);
    try {
      final response = await ApiClient.get('$baseUrl/getDaurahData');

      //print(response.body);
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

  Future<List<Daurah>> fetchDaurah() async {
    final response = await ApiClient.get("$baseUrl/daurah");

    print("DAURAH RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> listData = jsonData['data'];

      return List<Daurah>.from(listData.map((x) => Daurah.fromJson(x)));
    } else {
      throw Exception("Gagal mengambil daurah");
    }
  }

  Future<List<LaporanHafalan>> fetchLaporanByDaurah(int id, int periode) async {
    final response = await ApiClient.get(
      "$baseUrl/laporan-hafalan/$id?periode=$periode",
    );
    print("URL: $baseUrl/laporan-hafalan/$id?periode=$periode");
    print("LAPORAN HAFALAN RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> listData = jsonData['data'];

      return List<LaporanHafalan>.from(
        listData.map((x) => LaporanHafalan.fromJson(x)),
      );
    } else {
      throw Exception("Gagal mengambil laporan");
    }
  }
}
