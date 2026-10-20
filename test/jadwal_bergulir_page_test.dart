import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotmul_quran/model/jadwal_bergulir_model.dart';
import 'package:hotmul_quran/pages/jadwal_bergulir_page.dart';

JadwalBergulir _data() {
  final mulai = DateTime(2026, 10, 13);
  return JadwalBergulir.fromJson({
    'sekarang': {
      'period_index': 39318,
      'juz': 19,
      'start_date': '2026-10-13',
      'end_date': '2026-10-26',
      'status': 'active',
    },
    'hari': [
      for (var i = 0; i < 14; i++)
        {
          'tanggal': mulai
              .add(Duration(days: i))
              .toIso8601String()
              .substring(0, 10),
          'sudah_lapor': i < 3,
          'hari_ini': i == 7,
          'tenggat': i == 10 || i == 12,
        },
    ],
    'riwayat': [
      {
        'period_index': 39317,
        'juz': 18,
        'start_date': '2026-09-29',
        'end_date': '2026-10-12',
        'status': 'late',
      },
    ],
    'berikutnya': [
      {
        'period_index': 39319,
        'juz': 20,
        'start_date': '2026-10-27',
        'end_date': '2026-11-09',
        'status': 'terjadwal',
      },
    ],
  });
}

void main() {
  testWidgets('kalender tidak overflow di layar sempit dengan huruf besar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3; // 360 x 800 dp, seperti HP Android
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(1.3),
          ),
          child: JadwalBergulirPage(loader: () async => _data()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Juz 18'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Juz 18'), findsOneWidget);
    expect(find.textContaining('Periode 39318'), findsOneWidget);
  });
}
