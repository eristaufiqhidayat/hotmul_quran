int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

/// Satu periode juz (`GET /api/v1/jadwal-bergulir`).
class JadwalJuz {
  final int periodIndex;
  final int juz;
  final DateTime? startDate;
  final DateTime? endDate;

  /// active / done / late / terjadwal
  final String status;

  JadwalJuz({
    required this.periodIndex,
    required this.juz,
    this.startDate,
    this.endDate,
    required this.status,
  });

  factory JadwalJuz.fromJson(Map<String, dynamic> json) => JadwalJuz(
    periodIndex: _toInt(json['period_index']),
    juz: _toInt(json['juz']),
    startDate: _toDate(json['start_date']),
    endDate: _toDate(json['end_date']),
    status: json['status']?.toString() ?? '',
  );
}

class JadwalHari {
  final DateTime tanggal;
  final bool sudahLapor;
  final bool hariIni;
  final bool tenggat;

  JadwalHari({
    required this.tanggal,
    required this.sudahLapor,
    required this.hariIni,
    required this.tenggat,
  });

  factory JadwalHari.fromJson(Map<String, dynamic> json) => JadwalHari(
    tanggal: _toDate(json['tanggal']) ?? DateTime.now(),
    sudahLapor: json['sudah_lapor'] == true,
    hariIni: json['hari_ini'] == true,
    tenggat: json['tenggat'] == true,
  );
}

class JadwalBergulir {
  final JadwalJuz? sekarang;
  final List<JadwalHari> hari;
  final List<JadwalJuz> riwayat;
  final List<JadwalJuz> berikutnya;

  JadwalBergulir({
    this.sekarang,
    required this.hari,
    required this.riwayat,
    required this.berikutnya,
  });

  factory JadwalBergulir.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        (json[key] as List? ?? [])
            .map((e) => f(Map<String, dynamic>.from(e)))
            .toList();

    return JadwalBergulir(
      sekarang: json['sekarang'] is Map
          ? JadwalJuz.fromJson(Map<String, dynamic>.from(json['sekarang']))
          : null,
      hari: list('hari', JadwalHari.fromJson),
      riwayat: list('riwayat', JadwalJuz.fromJson),
      berikutnya: list('berikutnya', JadwalJuz.fromJson),
    );
  }
}
