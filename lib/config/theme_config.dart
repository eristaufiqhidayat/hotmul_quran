// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class ThemeConfig {
  // Colors
  static const Color sentraextro = Color.fromRGBO(0, 255, 110, 1);
  static const Color basicColor = Colors.green;
  static const Color fontdrawer = Color.fromRGBO(131, 5, 13, 1);
  static const Color fontdrawerhover = Color.fromRGBO(181, 176, 176, 1);
  static const Color putih = Color.fromRGBO(252, 251, 251, 1);
  static const Color Font = Color.fromRGBO(252, 251, 251, 1);
  static const Color greenlogo = Color(0xFF2E6407);
  static const Color primaryDark = Color(0xFF0F6312);

  // Warna status progres (SRS FR-05: hijau / kuning / merah)
  static const Color onTrack = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color late = Color(0xFFC62828);
  static const Color neutral = Color(0xFF9E9E9E);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: greenlogo,
      primary: primaryDark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF4F7F2),
      appBarTheme: const AppBarTheme(
        backgroundColor: greenlogo,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
