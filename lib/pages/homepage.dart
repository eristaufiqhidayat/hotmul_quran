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
    return const Scaffold(body: MainPage());
  }
}
