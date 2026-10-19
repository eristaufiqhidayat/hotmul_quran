import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/admin_monitoring_page.dart';
import 'package:hotmul_quran/pages/anggota/group_hotmul.dart';
import 'package:hotmul_quran/pages/daurah/group_daurah.dart';
import 'package:hotmul_quran/pages/badal_page.dart';
import 'package:hotmul_quran/pages/dokumentasi/dokumentasi_page.dart';
import 'package:hotmul_quran/pages/jadwal_bergulir_page.dart';
import 'package:hotmul_quran/pages/kas/kas_grup_page.dart';
import 'package:hotmul_quran/pages/jadwal/jadwal.dart';
import 'package:hotmul_quran/pages/khatam/khatam.dart';
import 'package:hotmul_quran/pages/khotmulperiode_page.dart';
import 'package:hotmul_quran/pages/laporan_hapalan_page.dart';
import 'package:hotmul_quran/pages/member_home_page.dart';
import 'package:hotmul_quran/pages/notification_page.dart';
import 'package:hotmul_quran/pages/reward/reward.dart';
import 'package:hotmul_quran/pages/setoranListPage.dart';

//import 'package:hotmul_quran/pages/khotmul/rekaman_audio.dart';

//import 'package:hotmul_quran/widget/drawer.dart';
class MenuItem {
  final String title;
  final IconData icon;

  /// Tampilkan label "Baru" di grid dashboard.
  final bool isNew;
  MenuItem(this.title, this.icon, {this.isNew = false});
}

/// Menu admin kelompok (BRD 3: membuat grup, mengatur anggota, memantau).
final List<MenuItem> menuItems = [
  MenuItem('Monitoring', Icons.insights),
  MenuItem('Anggota', Icons.person),
  MenuItem('Dauroh', Icons.menu),
  MenuItem('Khatam', Icons.check_circle),
  MenuItem('Donasi / Kas Grup', Icons.credit_card),
  MenuItem('Jadwal Khatam', Icons.calendar_today),
  MenuItem('Khotmul Periode', Icons.crisis_alert_outlined),
  MenuItem('Reward', Icons.card_giftcard),
  MenuItem('Laporan', Icons.pie_chart),
  MenuItem('Jadwal Bergulir', Icons.event_repeat, isNew: true),
  MenuItem('Badal', Icons.swap_horiz, isNew: true),
  MenuItem('Dokumentasi Khotaman', Icons.drive_folder_upload, isNew: true),
];

/// Menu anggota (BRD 3: lapor hafalan, lihat jadwal, notifikasi).
final List<MenuItem> menuItems2 = [
  MenuItem('Beranda Hafalan', Icons.home_outlined),
  MenuItem('Setoran Hafalan', Icons.edit_note),
  MenuItem('Jadwal Bergulir', Icons.event_repeat, isNew: true),
  MenuItem('Badal', Icons.swap_horiz, isNew: true),
  MenuItem('Notifikasi', Icons.notifications_outlined),
  MenuItem('Donasi / Kas Grup', Icons.credit_card),
  MenuItem('Jadwal Khatam', Icons.calendar_today),
  MenuItem('Reward', Icons.card_giftcard),
  MenuItem('Laporan', Icons.pie_chart),
  MenuItem('Dokumentasi Khotaman', Icons.drive_folder_upload, isNew: true),
];

/// Menu fitur BRD yang sama untuk admin dan anggota. Mengembalikan true
/// jika [title] ditangani di sini.
bool _onMenuBersama(BuildContext context, String title) {
  final Widget? page = switch (title) {
    'Donasi / Kas Grup' => const KasGrupPage(),
    'Jadwal Bergulir' => const JadwalBergulirPage(),
    'Badal' => const BadalPage(),
    'Dokumentasi Khotaman' => const DokumentasiPage(),
    _ => null,
  };
  if (page == null) return false;
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  return true;
}

void onMenuClick(BuildContext context, String title) {
  if (_onMenuBersama(context, title)) return;
  switch (title) {
    case 'Monitoring':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminMonitoringPage()),
      );
      break;
    case 'Anggota':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnggotaPage()),
      );
      break;
    case 'Dauroh':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DaurahPage()),
      );
      break;
    case 'Khatam':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminUpdateKhatamPage()),
      );
      break;
    case 'Jadwal Khatam':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => jadwalPage()),
      );
      break;
    case 'Reward':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RewardPage()),
      );
      break;
    case 'Laporan':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LaporanHafalanPage()),
      );
      break;
    case 'Khotmul Periode':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => KhotmulPeriode_Page()),
      );
      break;
    default:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Menu $title belum ada aksi")));
  }
}

void onMenuClick2(BuildContext context, String title) {
  if (_onMenuBersama(context, title)) return;
  switch (title) {
    case 'Beranda Hafalan':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MemberHomePage()),
      );
      break;
    case 'Notifikasi':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationPage()),
      );
      break;
    case 'Setoran Hafalan':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SetoranListPage()),
      );
      break;
    case 'Jadwal Khatam':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => jadwalPage()),
      );
      break;
    case 'Reward':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RewardPage()),
      );
      break;
    case 'Laporan':
      Navigator.push(
        context,
        //MaterialPageRoute(builder: (context) => ReportMain()),
        MaterialPageRoute(builder: (context) => LaporanHafalanPage()),
      );
      break;
    default:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Menu $title belum ada aksi")));
  }
}
