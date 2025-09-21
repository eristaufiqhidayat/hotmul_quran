class JuzData {
  final int id;
  final int juz;
  final int noSurahAwal;
  final int noAyahAwal;
  final int noSurahAkhir;
  final int noAyahAkhir;
  final int jumlahAyat;

  JuzData({
    required this.id,
    required this.juz,
    required this.noSurahAwal,
    required this.noAyahAwal,
    required this.noSurahAkhir,
    required this.noAyahAkhir,
    required this.jumlahAyat,
  });

  factory JuzData.fromJson(Map<String, dynamic> json) {
    return JuzData(
      id: json['id'] as int? ?? 0,
      juz: json['juz'] as int? ?? 0,
      noSurahAwal: json['noSurah_awal'] as int? ?? 0,
      noAyahAwal: json['noAyah_awal'] as int? ?? 0,
      noSurahAkhir: json['noSurah_akhir'] as int? ?? 0,
      noAyahAkhir: json['noAyah_akhir'] as int? ?? 0,
      jumlahAyat: json['jumlah_ayat'] as int? ?? 0,
    );
  }
}
