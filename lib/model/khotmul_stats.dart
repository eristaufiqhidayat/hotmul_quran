// lib/models/khotmul_stats.dart
class KhotmulStats {
  final String userId;
  final String groupId;
  final String name;
  final int jumlahKhotmul;
  final String daftarJuz;
  final String daftarTanggal;

  KhotmulStats({
    required this.userId,
    required this.groupId,
    required this.name,
    required this.jumlahKhotmul,
    required this.daftarJuz,
    required this.daftarTanggal,
  });

  factory KhotmulStats.fromJson(Map<String, dynamic> json) {
    return KhotmulStats(
      userId: json['user_id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      jumlahKhotmul: json['jumlah_khotmul'] != null
          ? int.parse(json['jumlah_khotmul'].toString())
          : 0,
      daftarJuz: json['daftar_juz']?.toString() ?? '',
      daftarTanggal: json['daftar_tanggal']?.toString() ?? '',
    );
  }
}

class KhotmulResponse {
  final bool success;
  final String message;
  final List<KhotmulStats> data;

  KhotmulResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory KhotmulResponse.fromJson(Map<String, dynamic> json) {
    return KhotmulResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => KhotmulStats.fromJson(item))
              .toList() ??
          [],
    );
  }
}
