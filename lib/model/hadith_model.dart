import 'dart:convert';
import 'package:http/http.dart' as http;

/// Kitab hadits (Bukhari, Muslim, dst.) dari api.hadith.gading.dev.
class HadithBook {
  final String id;
  final String name;
  final int available;

  HadithBook({required this.id, required this.name, required this.available});

  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      id: json['id'] as String,
      name: (json['name'] ?? json['id']) as String,
      available: (json['available'] as num?)?.toInt() ?? 0,
    );
  }

  /// Nama imam tanpa awalan "HR. ", mis. "Bukhari".
  String get shortName => name.replaceFirst(RegExp(r'^HR\.?\s*'), '');

  String get arabicName => _arabicNames[id] ?? '';

  String get author => _authors[id] ?? '';

  static const Map<String, String> _arabicNames = {
    'bukhari': 'صحيح البخاري',
    'muslim': 'صحيح مسلم',
    'abu-daud': 'سنن أبي داود',
    'tirmidzi': 'سنن الترمذي',
    'nasai': 'سنن النسائي',
    'ibnu-majah': 'سنن ابن ماجه',
    'ahmad': 'مسند أحمد',
    'malik': 'موطأ مالك',
    'darimi': 'سنن الدارمي',
  };

  static const Map<String, String> _authors = {
    'bukhari': 'Imam Muhammad bin Ismail al-Bukhari',
    'muslim': 'Imam Muslim bin al-Hajjaj',
    'abu-daud': 'Imam Abu Dawud as-Sijistani',
    'tirmidzi': 'Imam Abu Isa at-Tirmidzi',
    'nasai': 'Imam Ahmad bin Syu\'aib an-Nasa\'i',
    'ibnu-majah': 'Imam Muhammad bin Yazid Ibnu Majah',
    'ahmad': 'Imam Ahmad bin Hanbal',
    'malik': 'Imam Malik bin Anas',
    'darimi': 'Imam Abdullah bin Abdurrahman ad-Darimi',
  };

  /// Urutan tampilan: Kutubus Sittah dulu, lalu kitab lain.
  static const List<String> order = [
    'bukhari',
    'muslim',
    'abu-daud',
    'tirmidzi',
    'nasai',
    'ibnu-majah',
    'ahmad',
    'malik',
    'darimi',
  ];
}

class Hadith {
  final int number;
  final String arab;
  final String terjemah;

  Hadith({required this.number, required this.arab, required this.terjemah});

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      number: (json['number'] as num).toInt(),
      arab: (json['arab'] ?? '') as String,
      terjemah: (json['id'] ?? '') as String,
    );
  }
}

class HadithApi {
  static const String _base = 'https://api.hadith.gading.dev/books';

  /// Batas maksimal satu permintaan range dari API.
  static const int maxRange = 300;

  static Future<dynamic> _getData(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final map = json.decode(res.body) as Map<String, dynamic>;
    if (map['error'] == true) {
      throw Exception(map['message'] ?? 'Gagal memuat hadits');
    }
    return map['data'];
  }

  static Future<List<HadithBook>> fetchBooks() async {
    final data = await _getData(_base) as List;
    final books = data
        .map((e) => HadithBook.fromJson(e as Map<String, dynamic>))
        .toList();
    int rank(HadithBook b) {
      final i = HadithBook.order.indexOf(b.id);
      return i < 0 ? HadithBook.order.length : i;
    }

    books.sort((a, b) => rank(a).compareTo(rank(b)));
    return books;
  }

  /// Hadits nomor [start] sampai [end] (inklusif) dari kitab [bookId].
  static Future<List<Hadith>> fetchRange(
    String bookId,
    int start,
    int end,
  ) async {
    final data =
        await _getData('$_base/$bookId?range=$start-$end')
            as Map<String, dynamic>;
    return (data['hadiths'] as List)
        .map((e) => Hadith.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Hadith> fetchOne(String bookId, int number) async {
    final data =
        await _getData('$_base/$bookId/$number') as Map<String, dynamic>;
    return Hadith.fromJson(data['contents'] as Map<String, dynamic>);
  }
}
