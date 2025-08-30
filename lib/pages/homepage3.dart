// ===================== pubspec.yaml (tambahkan dependency) =====================
// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^1.2.2
//
// assets:
//   # (opsional) tambahkan aset bila perlu
//
// ============================================================================
// File: lib/main.dart
// Aplikasi contoh: tema hijau, tampilan detail surah mirip screenshot,
// data dari API https://api.quran.gading.dev/surah/{id}
//
// Catatan:
// - Audio/play, share, bookmark disiapkan sebagai stub (tanpa implementasi backend).
// - Ganti nilai `defaultSurahId` untuk memuat surah lain.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/surahDetil.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:http/http.dart' as http;

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0EA47A), // hijau dominan
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qur\'an',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF5FAF7),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SurahDetailPage(defaultSurahId: 1), // Al-Fatihah
    );
  }
}

class SurahDetailPage extends StatefulWidget {
  final int defaultSurahId;
  const SurahDetailPage({super.key, required this.defaultSurahId});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<Surah> futureSurah;
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SurahDetil(defaultSurahId: 1),
    SurahListPage(),
    SurahDetil(defaultSurahId: 1),
    DoaPage(),
    ProfilePage(),
  ];
  @override
  void initState() {
    super.initState();
    futureSurah = QuranApi.fetchSurah(widget.defaultSurahId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: PrimaryAppBar(title: 'Home Page'),
      //appBar: _buildTopBar(context),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Surat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            label: 'Qur\'an',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pan_tool_alt_outlined),
            label: 'Do\'a',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: _pages[_currentIndex],
    );
  }
}

// =============================== UI Pieces ===============================

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  late Future<List<Surah>> futureList;

  @override
  void initState() {
    super.initState();
    futureList = QuranApi.fetchAllSurah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Surah')),
      body: FutureBuilder<List<Surah>>(
        future: futureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = data[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${s.number}')),
                title: Text('${s.nameLatin} (${s.nameArabic})'),
                subtitle: Text('${s.translationId} • ${s.ayahCount} ayat'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahDetailPage(defaultSurahId: s.number),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Selamat datang di Aplikasi Qur\'an')),
    );
  }
}

class DoaPage extends StatelessWidget {
  const DoaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Do\'a')),
      body: const Center(child: Text('Kumpulan doa (coming soon)')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile user (coming soon)')),
    );
  }
}

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Qur’an Page", style: TextStyle(fontSize: 22)),
    );
  }
}

// =============================== DATA LAYER ===============================
class QuranApi {
  static const String _base = 'https://api.quran.gading.dev/surah';

  static Future<List<Surah>> fetchAllSurah() async {
    final uri = Uri.parse(_base);
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final map = json.decode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List).map((e) => Surah.fromApi(e)).toList();
    return list;
  }

  static Future<Surah> fetchSurah(int number) async {
    final uri = Uri.parse('$_base/$number');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final map = json.decode(res.body) as Map<String, dynamic>;
    return Surah.fromApi(map['data']);
  }
}

class Surah {
  final int number;
  final String nameArabic;
  final String nameLatin;
  final String translationId;
  final String revelationId; // Makkiyah/Madaniyah
  final int ayahCount;
  final List<Ayah> verses;

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameLatin,
    required this.translationId,
    required this.revelationId,
    required this.ayahCount,
    required this.verses,
  });

  factory Surah.fromApi(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      nameArabic: (json['name']?['short'] ?? '') as String,
      nameLatin: (json['name']?['transliteration']?['id'] ?? '') as String,
      translationId: (json['name']?['translation']?['id'] ?? '') as String,
      revelationId: (json['revelation']?['id'] ?? '') as String,
      ayahCount: json['numberOfVerses'] as int,
      verses: ((json['verses'] as List<dynamic>)
          .map((e) => Ayah.fromApi(e as Map<String, dynamic>))
          .toList()),
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
      audioUrl: (json['audio']?['primary'] ?? '') as String,
    );
  }
}
