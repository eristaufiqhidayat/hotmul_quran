import 'package:flutter_test/flutter_test.dart';
import 'package:hotmul_quran/core/tanggal_id.dart';

void main() {
  test('format rupiah dengan titik ribuan', () {
    expect(TanggalId.rupiah(0), 'Rp 0');
    expect(TanggalId.rupiah(1500000), 'Rp 1.500.000');
    expect(TanggalId.rupiah(-250000), '−Rp 250.000');
  });

  test('format tanggal pendek dan nama hari', () {
    final d = DateTime(2026, 10, 13);
    expect(TanggalId.pendek(d), '13 Okt');
    expect(TanggalId.lengkap(d), '13 Okt 2026');
    expect(TanggalId.namaHari(d), 'Sel');
  });
}
