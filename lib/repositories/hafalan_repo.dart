import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'dart:convert';

class HafalanRepo {
  final String baseUrl = GlobalConst.url + "/api";

  Future<bool> submit({
    required int assignmentId,
    required int ayatFrom,
    required int ayatTo,
    String? keterangan,
  }) async {
    final response = await ApiClient.post(
      "$baseUrl/hafalan",
      body: {
        "assignment_id": assignmentId,
        "ayat_from": ayatFrom,
        "ayat_to": ayatTo,
        "keterangan": keterangan,
      },
    );
    print("Response Log Hafalan: ${response.body}");
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
