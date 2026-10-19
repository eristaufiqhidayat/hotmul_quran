import 'package:flutter_test/flutter_test.dart';
import 'package:hotmul_quran/core/hijri.dart';

void main() {
  test('1 Muharram 1446 H jatuh sekitar 7–8 Juli 2024', () {
    final h = HijriDate.fromDate(DateTime(2024, 7, 8));
    expect(h.year, 1446);
    expect(h.month, 1);
    expect(h.day, inInclusiveRange(1, 2));
  });

  test('1 Ramadan 1445 H sekitar 11 Maret 2024', () {
    final h = HijriDate.fromDate(DateTime(2024, 3, 11));
    expect(h.year, 1445);
    expect(h.month, 9);
    expect(h.day, inInclusiveRange(1, 2));
  });

  test('nama bulan dan format', () {
    const h = HijriDate(1448, 5, 2);
    expect(h.monthName, 'Jumadil Awal');
    expect(h.toString(), '2 Jumadil Awal 1448 H');
  });
}
