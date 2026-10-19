import 'package:flutter/material.dart';

// Palet hijau yang sama dengan halaman baca surah.
const Color hadithGreen = Color(0xFF1B5E20);
const Color hadithGreenMid = Color(0xFF2E7D32);
const Color hadithGreenSoft = Color(0xFFE8F5E9);
const Color hadithPageBg = Color(0xFFF4F7F2);
const Color hadithArabicInk = Color(0xFF1C1C1C);

/// 7008 -> "7.008"
String formatNumber(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

class HadithErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HadithErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              '$message Periksa koneksi internet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: hadithGreenMid),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
