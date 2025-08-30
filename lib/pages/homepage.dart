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

import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/MainPage.dart';

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0EA47A), // hijau
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
      home: const MainPage(), // ⬅️ selalu mulai dari MainPage
    );
  }
}
