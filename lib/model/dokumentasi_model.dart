int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

/// Dokumentasi khotaman (`GET /api/v1/dokumentasi`).
class Dokumentasi {
  final int id;
  final int? periodIndex;
  final int? juz;

  /// foto / video / audio
  final String jenis;
  final String name;
  final String url;
  final int size;
  final DateTime? tanggal;
  final String? deskripsi;
  final int userId;
  final String? uploader;

  Dokumentasi({
    required this.id,
    this.periodIndex,
    this.juz,
    required this.jenis,
    required this.name,
    required this.url,
    required this.size,
    this.tanggal,
    this.deskripsi,
    required this.userId,
    this.uploader,
  });

  factory Dokumentasi.fromJson(Map<String, dynamic> json) => Dokumentasi(
    id: _toInt(json['id']),
    periodIndex: json['period_index'] == null
        ? null
        : _toInt(json['period_index']),
    juz: json['juz'] == null ? null : _toInt(json['juz']),
    jenis: json['jenis']?.toString() ?? 'foto',
    name: json['name']?.toString() ?? '',
    url: json['url']?.toString() ?? '',
    size: _toInt(json['size']),
    tanggal: DateTime.tryParse(json['tanggal']?.toString() ?? ''),
    deskripsi: json['deskripsi']?.toString(),
    userId: _toInt(json['user_id']),
    uploader: json['uploader']?.toString(),
  );
}

class DokumentasiList {
  final int? periodeAktif;
  final DateTime? batasUpload;
  final List<Dokumentasi> data;

  DokumentasiList({this.periodeAktif, this.batasUpload, required this.data});

  factory DokumentasiList.fromJson(Map<String, dynamic> json) {
    final aktif = json['periode_aktif'] as Map?;
    return DokumentasiList(
      periodeAktif: aktif == null ? null : _toInt(aktif['periode']),
      batasUpload: DateTime.tryParse(
        aktif?['tanggal_selesai']?.toString() ?? '',
      ),
      data: (json['data'] as List? ?? [])
          .map((e) => Dokumentasi.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
