int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
int? _toIntOrNull(dynamic v) => int.tryParse(v?.toString() ?? '');

/// Satu baris anggota dari `GET /api/v1/hafalan/today`.
class SetoranAnggota {
  final int userId;
  final String name;
  final int? juz;
  final int? orderNumber;
  final String statusAssignment; // active | done | late | none
  final bool sudahSetor;
  final int? ayatFrom;
  final int? ayatTo;
  final int totalAyat;
  final int targetAyat;
  final int? periodeIndex;

  SetoranAnggota({
    required this.userId,
    required this.name,
    this.juz,
    this.orderNumber,
    required this.statusAssignment,
    required this.sudahSetor,
    this.ayatFrom,
    this.ayatTo,
    required this.totalAyat,
    required this.targetAyat,
    this.periodeIndex,
  });

  factory SetoranAnggota.fromJson(Map<String, dynamic> json) {
    return SetoranAnggota(
      userId: _toInt(json['id']),
      name: json['name']?.toString() ?? '-',
      juz: _toIntOrNull(json['juz']),
      orderNumber: _toIntOrNull(json['order_number']),
      statusAssignment: json['status_assignment']?.toString() ?? 'none',
      sudahSetor: json['sudah_setor'] == true,
      ayatFrom: _toIntOrNull(json['ayat_from']),
      ayatTo: _toIntOrNull(json['ayat_to']),
      totalAyat: _toInt(json['total_ayat']),
      targetAyat: _toInt(json['target_ayat']),
      periodeIndex: _toIntOrNull(json['periode_index']),
    );
  }

  bool get bisaSetor =>
      statusAssignment == 'active' || statusAssignment == 'done';
}

/// Rekap setoran satu grup (respon lengkap `GET /api/v1/hafalan/today`).
class SetoranGroup {
  final int? groupId;
  final String groupName;
  final int? periode;
  final List<SetoranAnggota> anggota;

  SetoranGroup({
    this.groupId,
    required this.groupName,
    this.periode,
    required this.anggota,
  });

  factory SetoranGroup.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];
    return SetoranGroup(
      groupId: _toIntOrNull(json['group_id']),
      groupName: json['group_name']?.toString() ?? '-',
      periode: _toIntOrNull(json['periode']),
      anggota: list
          .whereType<Map>()
          .map((e) => SetoranAnggota.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  SetoranAnggota? byUser(int? userId) {
    for (final a in anggota) {
      if (a.userId == userId) return a;
    }
    return null;
  }
}
