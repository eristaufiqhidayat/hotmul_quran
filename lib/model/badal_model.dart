int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

/// Juz anggota tidak aktif yang bisa diambil alih (`GET /api/v1/badal`).
class KandidatBadal {
  final int assignmentId;
  final String name;
  final int juz;
  final String status;
  final int? hariTidakLapor;
  final int progres;
  final DateTime? endDate;

  KandidatBadal({
    required this.assignmentId,
    required this.name,
    required this.juz,
    required this.status,
    this.hariTidakLapor,
    required this.progres,
    this.endDate,
  });

  factory KandidatBadal.fromJson(Map<String, dynamic> json) => KandidatBadal(
    assignmentId: _toInt(json['assignment_id']),
    name: json['name']?.toString() ?? '-',
    juz: _toInt(json['juz']),
    status: json['status']?.toString() ?? '',
    hariTidakLapor: json['hari_tidak_lapor'] == null
        ? null
        : _toInt(json['hari_tidak_lapor']),
    progres: _toInt(json['progres']),
    endDate: _toDate(json['end_date']),
  );
}

/// Juz yang sedang / sudah dibadal oleh user login.
class BadalSaya {
  final int id;
  final int assignmentId;
  final int juz;
  final String status;
  final String? originalName;
  final int progres;
  final DateTime? endDate;

  BadalSaya({
    required this.id,
    required this.assignmentId,
    required this.juz,
    required this.status,
    this.originalName,
    required this.progres,
    this.endDate,
  });

  bool get aktif => status == 'active';

  factory BadalSaya.fromJson(Map<String, dynamic> json) => BadalSaya(
    id: _toInt(json['id']),
    assignmentId: _toInt(json['assignment_id']),
    juz: _toInt(json['juz']),
    status: json['status']?.toString() ?? '',
    originalName: json['original_name']?.toString(),
    progres: _toInt(json['progres']),
    endDate: _toDate(json['end_date']),
  );
}

class BadalInfo {
  final List<KandidatBadal> kandidat;
  final List<BadalSaya> badalSaya;
  final int jumlahBadge;

  BadalInfo({
    required this.kandidat,
    required this.badalSaya,
    required this.jumlahBadge,
  });

  factory BadalInfo.fromJson(Map<String, dynamic> json) => BadalInfo(
    kandidat: (json['kandidat'] as List? ?? [])
        .map((e) => KandidatBadal.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    badalSaya: (json['badal_saya'] as List? ?? [])
        .map((e) => BadalSaya.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    jumlahBadge: _toInt((json['badge'] as Map?)?['pengganti_aktif']),
  );
}
