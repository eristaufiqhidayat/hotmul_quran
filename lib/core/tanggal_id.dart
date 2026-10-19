/// Format tanggal & rupiah berbahasa Indonesia tanpa perlu
/// `initializeDateFormatting` (locale `id` belum dimuat di main.dart).
class TanggalId {
  static const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  /// 13 Okt
  static String pendek(DateTime d) => '${d.day} ${bulan[d.month - 1]}';

  /// 13 Okt 2026
  static String lengkap(DateTime d) => '${pendek(d)} ${d.year}';

  /// Sen, Sel, ...
  static String namaHari(DateTime d) => hari[d.weekday - 1];

  /// Rp 1.500.000
  static String rupiah(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${n < 0 ? '−' : ''}Rp $buf';
  }
}
