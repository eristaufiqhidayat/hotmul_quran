import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'dart:convert';

class AssignmentRepo {
  final String baseUrl = GlobalConst.url + "/api";

  Future<Map<String, dynamic>?> getToday() async {
    final response = await ApiClient.get("$baseUrl/assignments/today");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }
}
