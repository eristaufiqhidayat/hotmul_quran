import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'dart:convert';

class NotificationRepo {
  final String baseUrl = GlobalConst.url + "/api";

  Future<List<dynamic>> getAll() async {
    final response = await ApiClient.get("$baseUrl/notifications");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  }
}
