// lib/models/juz_stats_model.dart
class JuzStats {
  final String anggotaId;
  final String name;
  final String groupId;
  final int totalJuz;
  final String? daftarJuz;
  final String? tanggalPembacaan;
  final String? tanggalMulai;
  final String? tanggalTerakhir;
  final int? totalPeriode;
  final String? statusList;

  JuzStats({
    required this.anggotaId,
    required this.name,
    required this.groupId,
    required this.totalJuz,
    this.daftarJuz,
    this.tanggalPembacaan,
    this.tanggalMulai,
    this.tanggalTerakhir,
    this.totalPeriode,
    this.statusList,
  });

  factory JuzStats.fromJson(Map<String, dynamic> json) {
    return JuzStats(
      anggotaId: json['anggota_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      totalJuz: _parseInt(json['total_juz']),
      daftarJuz: json['daftar_juz']?.toString(),
      tanggalPembacaan: json['tanggal_pembacaan']?.toString(),
      tanggalMulai: json['tanggal_mulai']?.toString(),
      tanggalTerakhir: json['tanggal_terakhir']?.toString(),
      totalPeriode: _parseInt(json['total_periode']),
      statusList: json['status_list']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}

class JuzStatsResponse {
  final bool success;
  final String message;
  final List<JuzStats> data;
  final int? totalRecords;

  JuzStatsResponse({
    required this.success,
    required this.message,
    required this.data,
    this.totalRecords,
  });

  factory JuzStatsResponse.fromJson(Map<String, dynamic> json) {
    return JuzStatsResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => JuzStats.fromJson(item))
              .toList() ??
          [],
      totalRecords: _parseInt(json['total_records']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}

class JuzSummary {
  final int totalAnggota;
  final int totalJuzDibaca;
  final double persentaseAktif;
  final String? tanggalTerakhirAktivitas;

  JuzSummary({
    required this.totalAnggota,
    required this.totalJuzDibaca,
    required this.persentaseAktif,
    this.tanggalTerakhirAktivitas,
  });

  factory JuzSummary.fromJson(Map<String, dynamic> json) {
    return JuzSummary(
      totalAnggota: _parseInt(json['total_anggota']),
      totalJuzDibaca: _parseInt(json['total_juz_dibaca']),
      persentaseAktif: _parseDouble(json['persentase_aktif']),
      tanggalTerakhirAktivitas: json['tanggal_terakhir_aktivitas']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
