import 'package:hotmul_quran/const/global_const.dart';

/// Status progres anggota sesuai SRS FR-05 (hijau / kuning / merah).
enum ProgressLevel { onTrack, warning, late }

/// Aturan bisnis hafalan dari README (BRD/SRS) dalam bentuk fungsi murni
/// supaya mudah diuji dan dipakai ulang di semua halaman.
class HafalanRules {
  HafalanRules._();

  /// Juz untuk anggota pada periode tertentu. Sama dengan rumus
  /// `RollingJuzService` di hotmul_api:
  /// `juz = (order_number + period - 1) % 30`, dengan 0 menjadi 30.
  static int juzForPeriod({required int orderNumber, required int period}) {
    final juz = (orderNumber + period - 1) % GlobalConst.totalJuz;
    return juz == 0 ? GlobalConst.totalJuz : juz;
  }

  /// Persentase 0..1, aman untuk target 0.
  static double progress(int done, int target) {
    if (target <= 0) return 0;
    return (done / target).clamp(0, 1).toDouble();
  }

  /// Hari ke berapa dalam periode 14 hari (1-based, dibatasi 1..14+).
  static int dayOfPeriod(DateTime start, DateTime today) {
    final d = _dateOnly(today).difference(_dateOnly(start)).inDays + 1;
    return d < 1 ? 1 : d;
  }

  /// Sisa hari sampai tenggat (0 = hari terakhir, negatif = lewat).
  static int daysRemaining(DateTime end, DateTime today) {
    return _dateOnly(end).difference(_dateOnly(today)).inDays;
  }

  /// Warna progres:
  /// - hijau  jika progres > 80% atau assignment sudah `done`
  /// - merah  jika status `late`, tenggat lewat, atau < 50% pada hari ke-10+
  /// - kuning selain itu
  static ProgressLevel level({
    required double progress,
    required int dayOfPeriod,
    String? status,
    int? daysRemaining,
  }) {
    if (status == 'done' || progress > 0.8) return ProgressLevel.onTrack;
    if (status == 'late') return ProgressLevel.late;
    if (daysRemaining != null && daysRemaining < 0) return ProgressLevel.late;
    if (dayOfPeriod >= 10 && progress < 0.5) return ProgressLevel.late;
    return ProgressLevel.warning;
  }

  /// Pengingat tenggat H-3 dan H-1 (BRD 4.4).
  static String? deadlineReminder(int daysRemaining, {int? juz}) {
    final label = juz != null ? 'Juz $juz' : 'hafalan';
    if (daysRemaining == 3) return 'Tenggat $label tinggal 3 hari lagi.';
    if (daysRemaining == 1) {
      return 'Deadline besok! Laporkan $label-mu sekarang.';
    }
    if (daysRemaining == 0) return 'Hari ini batas akhir setoran $label.';
    if (daysRemaining < 0) return 'Tenggat $label sudah lewat.';
    return null;
  }

  /// Anggota dianggap tidak aktif bila tidak lapor selama 14 hari (FR-06).
  static bool isInactive(DateTime? lastReport, DateTime today) {
    if (lastReport == null) return true;
    return daysRemaining(today, lastReport) >= GlobalConst.hariPerPeriode;
  }

  /// Validasi input setoran ayat. Mengembalikan pesan error atau null.
  static String? validateAyatRange(int? from, int? to, {int? maxAyat}) {
    if (from == null || to == null) return 'Ayat harus berupa angka';
    if (from < 1) return 'Ayat awal minimal 1';
    if (from > to) return 'Ayat awal tidak boleh melebihi ayat akhir';
    if (maxAyat != null && maxAyat > 0 && to > maxAyat) {
      return 'Ayat akhir maksimal $maxAyat';
    }
    return null;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
