import 'dart:convert';

import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/model/laporan_hapalan_model.dart';
import 'package:hotmul_quran/service/api_client.dart';

Future<List<LaporanHafalan>> fetchLaporan() async {
  final response = await ApiClient.get(
    "${GlobalConst.url}/api/laporan-hafalan",
  );

  final body = jsonDecode(response.body);

  final data = body['data'] ?? [];
  return List.from(data).map((e) => LaporanHafalan.fromJson(e)).toList();
}
