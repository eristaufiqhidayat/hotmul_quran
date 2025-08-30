// lib/models/surah.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Surah {
  final int number;
  final String nameArabic;
  final String nameLatin;
  final String translationId;
  final String revelationId;
  final int ayahCount;
  final List<Ayah>? verses;

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameLatin,
    required this.translationId,
    required this.revelationId,
    required this.ayahCount,
    this.verses,
  });

  factory Surah.fromList(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      nameArabic: (json['name']?['short'] ?? '') as String,
      nameLatin:
          (json['name']?['transliteration']?['id'] ??
                  json['name']?['transliteration']?['en'] ??
                  '')
              as String,
      translationId: (json['name']?['translation']?['id'] ?? '') as String,
      revelationId: (json['revelation']?['id'] ?? '') as String,
      ayahCount: json['numberOfVerses'] as int,
      verses: null,
    );
  }

  factory Surah.fromDetail(Map<String, dynamic> json) {
    final versesJson = json['verses'] as List<dynamic>?;
    return Surah(
      number: json['number'] as int,
      nameArabic: (json['name']?['short'] ?? '') as String,
      nameLatin:
          (json['name']?['transliteration']?['id'] ??
                  json['name']?['transliteration']?['en'] ??
                  '')
              as String,
      translationId: (json['name']?['translation']?['id'] ?? '') as String,
      revelationId: (json['revelation']?['id'] ?? '') as String,
      ayahCount: json['numberOfVerses'] as int,
      verses: versesJson
          ?.map((e) => Ayah.fromApi(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Ayah {
  final int inSurahNumber;
  final String arabic;
  final String translationId;
  final String? audioUrl;

  Ayah({
    required this.inSurahNumber,
    required this.arabic,
    required this.translationId,
    this.audioUrl,
  });

  factory Ayah.fromApi(Map<String, dynamic> json) {
    return Ayah(
      inSurahNumber: json['number']?['inSurah'] as int,
      arabic: (json['text']?['arab'] ?? '') as String,
      translationId: (json['translation']?['id'] ?? '') as String,
      audioUrl: json['audio']?['primary'] as String?,
    );
  }
}

class QuranApi {
  static const String _base = 'https://api.quran.gading.dev/surah';

  static Future<List<Surah>> fetchAllSurah() async {
    final res = await http.get(Uri.parse(_base));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final map = json.decode(res.body) as Map<String, dynamic>;
    return (map['data'] as List)
        .map((e) => Surah.fromList(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Surah> fetchSurah(int number) async {
    final res = await http.get(Uri.parse('$_base/$number'));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final map = json.decode(res.body) as Map<String, dynamic>;
    return Surah.fromDetail(map['data'] as Map<String, dynamic>);
  }
}
