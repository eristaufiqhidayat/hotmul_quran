import 'dart:convert';
import 'package:http/http.dart' as http;

/// Kitab hadits yang punya terjemah Indonesia di Hadith API (fawazahmed0),
/// disajikan lewat CDN jsDelivr. Daftarnya disimpan di aplikasi supaya
/// halaman kitab tidak bergantung pada server.
class HadithBook {
  final String id;
  final String name;
  final String arabicName;
  final String author;

  const HadithBook({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.author,
  });

  /// Nama imam tanpa awalan "HR. ", mis. "Bukhari".
  String get shortName => name.replaceFirst(RegExp(r'^HR\.?\s*'), '');

  static const List<HadithBook> all = [
    HadithBook(
      id: 'bukhari',
      name: 'HR. Bukhari',
      arabicName: 'صحيح البخاري',
      author: 'Imam Muhammad bin Ismail al-Bukhari',
    ),
    HadithBook(
      id: 'muslim',
      name: 'HR. Muslim',
      arabicName: 'صحيح مسلم',
      author: 'Imam Muslim bin al-Hajjaj',
    ),
    HadithBook(
      id: 'abudawud',
      name: 'HR. Abu Dawud',
      arabicName: 'سنن أبي داود',
      author: 'Imam Abu Dawud as-Sijistani',
    ),
    HadithBook(
      id: 'tirmidhi',
      name: 'HR. Tirmidzi',
      arabicName: 'جامع الترمذي',
      author: 'Imam Abu Isa at-Tirmidzi',
    ),
    HadithBook(
      id: 'nasai',
      name: 'HR. Nasa\'i',
      arabicName: 'سنن النسائي',
      author: 'Imam Ahmad bin Syu\'aib an-Nasa\'i',
    ),
    HadithBook(
      id: 'ibnmajah',
      name: 'HR. Ibnu Majah',
      arabicName: 'سنن ابن ماجه',
      author: 'Imam Muhammad bin Yazid Ibnu Majah',
    ),
    HadithBook(
      id: 'malik',
      name: 'HR. Malik',
      arabicName: 'موطأ مالك',
      author: 'Imam Malik bin Anas',
    ),
  ];
}

class Hadith {
  final int number;
  final String arab;
  final String terjemah;

  Hadith({required this.number, required this.arab, required this.terjemah});
}

/// Satu bagian (kitab/bab) dari sebuah kitab hadits.
class HadithSection {
  final int number;
  final String title;
  final List<Hadith> hadiths;

  HadithSection({
    required this.number,
    required this.title,
    required this.hadiths,
  });
}

class HadithNotFound implements Exception {}

class HadithApi {
  static const String _base =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

  static Future<Map<String, dynamic>> _getJson(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 404) throw HadithNotFound();
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// Ambil edisi Indonesia dan Arab untuk [path] lalu gabungkan per nomor.
  static Future<(Map<String, dynamic>, List<Hadith>)> _fetchPair(
    String bookId,
    String path,
  ) async {
    final results = await Future.wait([
      _getJson('$_base/ind-$bookId/$path.min.json'),
      _getJson('$_base/ara-$bookId/$path.min.json'),
    ]);
    final ind = results[0];
    final ara = results[1];

    int numberOf(dynamic h) => (h['hadithnumber'] as num).toInt();
    final arabByNumber = <int, String>{
      for (final h in ara['hadiths'] as List)
        numberOf(h): (h['text'] ?? '') as String,
    };
    final hadiths = <Hadith>[];
    for (final h in ind['hadiths'] as List) {
      final n = numberOf(h);
      final arab = arabByNumber[n] ?? '';
      final terjemah = ((h['text'] ?? '') as String).trim();
      if (arab.isEmpty && terjemah.isEmpty) continue;
      hadiths.add(Hadith(number: n, arab: arab, terjemah: terjemah));
    }
    return (ind['metadata'] as Map<String, dynamic>, hadiths);
  }

  /// Bagian ke-[number]; melempar [HadithNotFound] bila tidak ada.
  static Future<HadithSection> fetchSection(String bookId, int number) async {
    final (meta, hadiths) = await _fetchPair(bookId, 'sections/$number');
    final section = meta['section'];
    final title = section is Map ? (section['$number'] ?? '') as String : '';
    return HadithSection(number: number, title: title, hadiths: hadiths);
  }

  static Future<Hadith> fetchOne(String bookId, int number) async {
    final (_, hadiths) = await _fetchPair(bookId, '$number');
    if (hadiths.isEmpty) throw HadithNotFound();
    return hadiths.first;
  }
}
