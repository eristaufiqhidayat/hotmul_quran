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
  final Set<int> _bookmarks = <int>{};

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
      bottomNavigationBar: _BottomNav(),
      body: SafeArea(
        child: FutureBuilder<Surah>(
          future: futureSurah,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingSkeleton();
            }
            if (snapshot.hasError) {
              return _ErrorState(
                message: 'Gagal memuat data surah.\n${snapshot.error}',
                onRetry: () {
                  setState(() {
                    futureSurah = QuranApi.fetchSurah(widget.defaultSurahId);
                  });
                },
              );
            }

            final surah = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  futureSurah = QuranApi.fetchSurah(surah.number);
                });
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _SurahHeaderCard(surah: surah)),
                  SliverList.separated(
                    itemCount: surah.verses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final v = surah.verses[index];
                      final bookmarked = _bookmarks.contains(v.inSurahNumber);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _AyahTile(
                          ayah: v,
                          onShare: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fitur share belum diimplementasi.',
                                ),
                              ),
                            );
                          },
                          onPlay: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Putar audio ayat ${v.inSurahNumber} (stub).',
                                ),
                              ),
                            );
                          },
                          bookmarked: bookmarked,
                          onToggleBookmark: () {
                            setState(() {
                              if (bookmarked) {
                                _bookmarks.remove(v.inSurahNumber);
                              } else {
                                _bookmarks.add(v.inSurahNumber);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            child: const Text('E', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good Morning 👋',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                'Eris Taufiq',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      ],
    );
  }
}

// =============================== UI Pieces ===============================
class _SurahHeaderCard extends StatelessWidget {
  final Surah surah;
  const _SurahHeaderCard({required this.surah});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${surah.nameLatin} (${surah.nameArabic})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              surah.translationId,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _HeaderActionDivider(),
                Row(
                  children: const [
                    Icon(Icons.share_outlined, color: Colors.white70),
                    SizedBox(width: 6),
                    Text('Bagikan', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                Row(children: const [SizedBox(width: 6)]),
                const Icon(
                  Icons.play_circle_fill,
                  size: 42,
                  color: Colors.white,
                ),
                const _HeaderActionDivider(),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${surah.revelationId} • ${surah.ayahCount} AYAT',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionDivider extends StatelessWidget {
  const _HeaderActionDivider();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.6,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _AyahTile extends StatelessWidget {
  final Ayah ayah;
  final VoidCallback onShare;
  final VoidCallback onPlay;
  final VoidCallback onToggleBookmark;
  final bool bookmarked;

  const _AyahTile({
    required this.ayah,
    required this.onShare,
    required this.onPlay,
    required this.onToggleBookmark,
    required this.bookmarked,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  radius: 20,
                  child: Text(
                    '${ayah.inSurahNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الفاتحة (Juz: 1)',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined),
                ),
                IconButton(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_circle_outline),
                ),
                IconButton(
                  onPressed: onToggleBookmark,
                  icon: Icon(
                    bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  ayah.arabic,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ayah.translationId,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  // const _BottomNav();
  // final List<Widget> _pages = const [
  //   HomePage(),
  //   SurahListPage(),
  //   QuranPage(),
  //   DoaPage(),
  //   ProfilePage(),
  // ];
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      decoration: BoxDecoration(
        color: scheme.primary,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(icon: Icons.grid_view_rounded, label: 'Home'),
          _BottomItem(icon: Icons.menu_book_outlined, label: 'Surat'),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.auto_stories_outlined,
              color: scheme.primary,
              size: 36,
            ),
          ),
          _BottomItem(icon: Icons.pan_tool_alt_outlined, label: 'Do\'a'),
          _BottomItem(icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BottomItem({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 2),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
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

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    final base = Colors.green.shade100;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: i == 0 ? 200 : 110,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

// =============================== DATA LAYER ===============================
class QuranApi {
  static const String _base = 'https://api.quran.gading.dev/surah';

  static Future<Surah> fetchSurah(int number) async {
    final uri = Uri.parse('$_base/$number');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    return Surah.fromApi(map['data'] as Map<String, dynamic>);
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
