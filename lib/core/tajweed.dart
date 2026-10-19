import 'package:flutter/material.dart';

/// Hukum tajwid yang dipakai oleh edisi `quran-tajweed` di api.alquran.cloud.
///
/// Teks dari edisi itu berisi penanda seperti `[h:9421[ٱ]` atau `[n[ـٰ]`:
/// huruf setelah `[` pertama adalah kode hukum, `:angka` opsional, lalu teks
/// yang terkena hukum tersebut di dalam `[...]`.
class TajweedRule {
  final String code;
  final String name;
  final Color color;

  const TajweedRule(this.code, this.name, this.color);
}

class Tajweed {
  Tajweed._();

  /// Warna standar mushaf tajwid (skema alquran.cloud / globalquran).
  static const Map<String, TajweedRule> rules = {
    'h': TajweedRule('h', 'Hamzah Washal', Color(0xFFAAAAAA)),
    's': TajweedRule('s', 'Tidak dibaca', Color(0xFFAAAAAA)),
    'l': TajweedRule('l', 'Lam Syamsiyah', Color(0xFFAAAAAA)),
    'n': TajweedRule('n', 'Mad Thabi\'i (2 harakat)', Color(0xFF537FFF)),
    'p': TajweedRule('p', 'Mad Jaiz (2/4/6 harakat)', Color(0xFF4050FF)),
    'o': TajweedRule('o', 'Mad Wajib (4-5 harakat)', Color(0xFF2144C1)),
    'm': TajweedRule('m', 'Mad Lazim (6 harakat)', Color(0xFF000EBC)),
    'q': TajweedRule('q', 'Qalqalah', Color(0xFFDD0008)),
    'c': TajweedRule('c', 'Ikhfa Syafawi', Color(0xFFD500B7)),
    'f': TajweedRule('f', 'Ikhfa', Color(0xFF9400A8)),
    'w': TajweedRule('w', 'Idgham Mimi', Color(0xFF58B800)),
    'i': TajweedRule('i', 'Iqlab', Color(0xFF26BFFD)),
    'a': TajweedRule('a', 'Idgham Bighunnah', Color(0xFF169777)),
    'u': TajweedRule('u', 'Idgham Bilaghunnah', Color(0xFF169200)),
    'd': TajweedRule('d', 'Idgham Mutajanisain', Color(0xFFA1A1A1)),
    'b': TajweedRule('b', 'Idgham Mutaqaribain', Color(0xFFA1A1A1)),
    'g': TajweedRule('g', 'Ghunnah (2 harakat)', Color(0xFFFF7E1E)),
  };

  /// Urutan yang ditampilkan di panduan warna (Lam Syamsiyah & Tidak dibaca
  /// berwarna sama dengan Hamzah Washal, jadi cukup satu entri abu-abu).
  static const List<String> legendCodes = [
    'g',
    'f',
    'c',
    'i',
    'a',
    'u',
    'w',
    'q',
    'n',
    'p',
    'o',
    'm',
    'h',
    'd',
  ];

  static final RegExp _marker = RegExp(r'\[([a-z])(?::\d+)?\[([^\[\]]*)\]');

  /// Memecah teks bertanda tajwid menjadi potongan teks + hukumnya
  /// (`rule == null` untuk teks biasa).
  static List<TajweedSegment> parse(String text) {
    final segments = <TajweedSegment>[];
    var last = 0;
    for (final m in _marker.allMatches(text)) {
      if (m.start > last) {
        segments.add(TajweedSegment(_clean(text.substring(last, m.start))));
      }
      segments.add(TajweedSegment(m.group(2)!, rules[m.group(1)]));
      last = m.end;
    }
    if (last < text.length) {
      segments.add(TajweedSegment(_clean(text.substring(last))));
    }
    return segments.where((s) => s.text.isNotEmpty).toList();
  }

  /// Teks Arab polos tanpa penanda tajwid.
  static String plain(String text) => parse(text).map((s) => s.text).join();

  /// Membuang basmalah di awal ayat pertama (selain Al-Fatihah) karena
  /// basmalah sudah ditampilkan sebagai kepala surah.
  static List<TajweedSegment> stripLeadingBismillah(
    List<TajweedSegment> segments,
  ) {
    final text = segments.map((s) => s.text).join();
    final words = text.trimLeft().split(RegExp(r'\s+'));
    if (words.length <= 4) return segments;
    final head = words.take(4).map(_letters).join(' ');
    if (head != 'بسم الله الرحمن الرحيم') return segments;

    // Hitung panjang 4 kata pertama beserta spasi sesudahnya.
    final match = RegExp(r'^\s*(?:\S+\s+){4}').firstMatch(text);
    if (match == null) return segments;
    var drop = match.end;

    final result = <TajweedSegment>[];
    for (final s in segments) {
      if (drop >= s.text.length) {
        drop -= s.text.length;
        continue;
      }
      result.add(
        drop == 0 ? s : TajweedSegment(s.text.substring(drop), s.rule),
      );
      drop = 0;
    }
    return result;
  }

  /// Hanya huruf hijaiyah (tanpa harakat & tanda waqaf), alif washal → alif.
  static String _letters(String word) =>
      word.replaceAll('ٱ', 'ا').replaceAll(RegExp(r'[^ء-غف-ي]'), '');

  static String _clean(String text) => text.replaceAll(RegExp(r'[\[\]]'), '');

  /// Angka Arab-Indik untuk nomor ayat (mis. 12 → ١٢).
  static String arabicNumber(int n) => n
      .toString()
      .split('')
      .map((d) => String.fromCharCode(0x0660 + int.parse(d)))
      .join();
}

class TajweedSegment {
  final String text;
  final TajweedRule? rule;

  const TajweedSegment(this.text, [this.rule]);
}
