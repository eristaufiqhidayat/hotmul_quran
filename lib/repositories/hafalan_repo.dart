import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/model/assignment_model.dart';
import 'package:hotmul_quran/model/setoran_model.dart';
import 'package:hotmul_quran/service/api_client.dart';

/// Akses endpoint hafalan harian di hotmul_api.
class HafalanRepo {
  static const String baseUrl = GlobalConst.apiV1;

  /// `GET /assignment-active` → null bila belum ada juz aktif (404).
  Future<Assignment?> getActiveAssignment() async {
    final response = await ApiClient.get("$baseUrl/assignment-active");
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    return Assignment.fromJson(ApiClient.decode(response));
  }

  /// `GET /hafalan/today` → rekap setoran grup user login.
  Future<SetoranGroup> getSetoranHariIni() async {
    final response = await ApiClient.get("$baseUrl/hafalan/today");
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode == 500
            ? 'Akun belum dimasukkan ke grup atau periode aktif belum dibuat admin.'
            : ApiClient.errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    return SetoranGroup.fromJson(ApiClient.decode(response));
  }

  /// `POST /hafalan` → simpan laporan harian. Mengembalikan pesan sukses.
  Future<String> submit({
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
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiClient.errorMessage(response, fallback: 'Setoran berhasil');
    }
    throw ApiException(
      ApiClient.errorMessage(response, fallback: 'Gagal kirim setoran'),
      statusCode: response.statusCode,
    );
  }
}
