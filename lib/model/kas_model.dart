int _toInt(dynamic v) => num.tryParse(v?.toString() ?? '')?.toInt() ?? 0;

/// Transaksi kas grup (`GET /api/v1/kas`).
class KasTransaksi {
  final int id;
  final int? userId;
  final String? name;

  /// masuk / keluar
  final String jenis;
  final DateTime? tanggal;
  final int nominal;
  final String? metode;
  final String? keterangan;
  final bool isVerified;

  KasTransaksi({
    required this.id,
    this.userId,
    this.name,
    required this.jenis,
    this.tanggal,
    required this.nominal,
    this.metode,
    this.keterangan,
    required this.isVerified,
  });

  bool get masuk => jenis == 'masuk';

  factory KasTransaksi.fromJson(Map<String, dynamic> json) => KasTransaksi(
    id: _toInt(json['id']),
    userId: json['user_id'] == null ? null : _toInt(json['user_id']),
    name: json['name']?.toString(),
    jenis: json['jenis']?.toString() ?? 'masuk',
    tanggal: DateTime.tryParse(json['tanggal']?.toString() ?? ''),
    nominal: _toInt(json['nominal']),
    metode: json['metode']?.toString(),
    keterangan: json['keterangan']?.toString(),
    isVerified: json['is_verified'] == true || json['is_verified'] == 1,
  );
}

class KasRingkasan {
  final String? groupName;
  final int saldo;
  final int masuk;
  final int keluar;
  final int menungguVerifikasi;
  final List<KasTransaksi> data;

  KasRingkasan({
    this.groupName,
    required this.saldo,
    required this.masuk,
    required this.keluar,
    required this.menungguVerifikasi,
    required this.data,
  });

  factory KasRingkasan.fromJson(Map<String, dynamic> json) => KasRingkasan(
    groupName: json['group_name']?.toString(),
    saldo: _toInt(json['saldo']),
    masuk: _toInt(json['masuk']),
    keluar: _toInt(json['keluar']),
    menungguVerifikasi: _toInt(json['menunggu_verifikasi']),
    data: (json['data'] as List? ?? [])
        .map((e) => KasTransaksi.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}
