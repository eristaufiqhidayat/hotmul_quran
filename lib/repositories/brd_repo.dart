import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/model/badal_model.dart';
import 'package:hotmul_quran/model/dokumentasi_model.dart';
import 'package:hotmul_quran/model/jadwal_bergulir_model.dart';
import 'package:hotmul_quran/model/kas_model.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:http/http.dart' as http;

/// Endpoint fitur BRD tambahan di hotmul_api: jadwal bergulir, badal,
/// kas grup, dan dokumentasi khotaman.
class BrdRepo {
  static const String baseUrl = GlobalConst.apiV1;

  dynamic _ok(http.Response r, {String? fallback}) {
    if (r.statusCode >= 200 && r.statusCode < 300) return ApiClient.decode(r);
    throw ApiException(
      ApiClient.errorMessage(r, fallback: fallback),
      statusCode: r.statusCode,
    );
  }

  String _message(http.Response r, String fallback) {
    _ok(r, fallback: fallback);
    return ApiClient.errorMessage(r, fallback: fallback);
  }

  // ---------- Jadwal bergulir ----------

  Future<JadwalBergulir> getJadwalBergulir() async {
    final r = await ApiClient.get("$baseUrl/jadwal-bergulir");
    return JadwalBergulir.fromJson(Map<String, dynamic>.from(_ok(r)));
  }

  // ---------- Badal ----------

  Future<BadalInfo> getBadal() async {
    final r = await ApiClient.get("$baseUrl/badal");
    return BadalInfo.fromJson(Map<String, dynamic>.from(_ok(r)));
  }

  Future<String> ambilAlih(int assignmentId) async {
    final r = await ApiClient.post("$baseUrl/badal/$assignmentId/ambil");
    return _message(r, 'Gagal mengambil alih juz');
  }

  Future<String> batalBadal(int badalId) async {
    final r = await ApiClient.post("$baseUrl/badal/$badalId/batal");
    return _message(r, 'Gagal membatalkan badal');
  }

  /// Jumlah badge "Pengganti Aktif" user login (0 jika gagal).
  Future<int> jumlahBadge() async {
    try {
      final r = await ApiClient.get("$baseUrl/badges");
      final body = _ok(r);
      return int.tryParse(body['pengganti_aktif']?.toString() ?? '') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ---------- Kas grup ----------

  Future<KasRingkasan> getKas({int? periode}) async {
    final q = periode == null ? '' : '?periode=$periode';
    final r = await ApiClient.get("$baseUrl/kas$q");
    return KasRingkasan.fromJson(Map<String, dynamic>.from(_ok(r)));
  }

  Future<String> tambahKas({
    required String jenis,
    required DateTime tanggal,
    required int nominal,
    String? metode,
    String? keterangan,
  }) async {
    final r = await ApiClient.post(
      "$baseUrl/kas",
      body: {
        "jenis": jenis,
        "tanggal": tanggal.toIso8601String().substring(0, 10),
        "nominal": nominal,
        "metode": metode,
        "keterangan": keterangan,
      },
    );
    return _message(r, 'Gagal menyimpan transaksi');
  }

  Future<String> verifikasiKas(int id) async {
    final r = await ApiClient.post("$baseUrl/kas/$id/verifikasi");
    return _message(r, 'Gagal verifikasi');
  }

  Future<String> hapusKas(int id) async {
    final r = await ApiClient.delete("$baseUrl/kas/$id");
    return _message(r, 'Gagal menghapus');
  }

  /// Isi CSV laporan kas (dibuka di Excel / Google Sheets).
  Future<List<int>> exportKas({int? periode}) async {
    final q = periode == null ? '' : '?periode=$periode';
    final r = await ApiClient.get("$baseUrl/kas/export$q");
    if (r.statusCode != 200) {
      throw ApiException(
        ApiClient.errorMessage(r, fallback: 'Gagal ekspor'),
        statusCode: r.statusCode,
      );
    }
    return r.bodyBytes;
  }

  // ---------- Dokumentasi khotaman ----------

  Future<DokumentasiList> getDokumentasi({int? periode}) async {
    final q = periode == null ? '' : '?periode=$periode';
    final r = await ApiClient.get("$baseUrl/dokumentasi$q");
    return DokumentasiList.fromJson(Map<String, dynamic>.from(_ok(r)));
  }

  Future<String> uploadDokumentasi({
    required String path,
    String? deskripsi,
    int? juz,
    DateTime? tanggal,
  }) async {
    final r = await ApiClient.postMultipart(
      "$baseUrl/dokumentasi",
      fields: {
        if (deskripsi != null && deskripsi.isNotEmpty) 'deskripsi': deskripsi,
        if (juz != null) 'juz': '$juz',
        if (tanggal != null)
          'tanggal': tanggal.toIso8601String().substring(0, 10),
      },
      files: {'file': path},
    );
    if (r.statusCode == 413) {
      throw ApiException('File terlalu besar untuk server (maks 50 MB)');
    }
    return _message(r, 'Gagal mengunggah');
  }

  Future<String> hapusDokumentasi(int id) async {
    final r = await ApiClient.delete("$baseUrl/dokumentasi/$id");
    return _message(r, 'Gagal menghapus');
  }
}
