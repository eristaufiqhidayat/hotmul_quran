import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/anggota/group_hotmul.dart';
import 'package:hotmul_quran/pages/daurah/group_daurah.dart';
import 'package:hotmul_quran/pages/donasi/donasi.dart';
import 'package:hotmul_quran/pages/jadwal/jadwal.dart';
import 'package:hotmul_quran/pages/khatam/khatam.dart';
import 'package:hotmul_quran/pages/khotmul/khotmul.dart';
import 'package:hotmul_quran/pages/report/report.dart';
import 'package:hotmul_quran/pages/reward/reward.dart';
//import 'package:hotmul_quran/pages/khotmul/rekaman_audio.dart';

//import 'package:hotmul_quran/widget/drawer.dart';
class MenuItem {
  final String title;
  final IconData icon;
  MenuItem(this.title, this.icon);
}

final List<MenuItem> menuItems = [
  MenuItem('Anggota', Icons.person),
  MenuItem('Dauroh', Icons.menu),
  MenuItem('Khatam', Icons.check_circle),
  MenuItem('Donasi', Icons.credit_card),
  MenuItem('Jadwal Khatam', Icons.calendar_today),
  MenuItem('Khotmul Periode', Icons.crisis_alert_outlined),
  MenuItem('Reward', Icons.card_giftcard),
  MenuItem('Laporan', Icons.pie_chart),
];

final List<MenuItem> menuItems2 = [
  MenuItem('Khotmul', Icons.person),
  MenuItem('Donasi', Icons.credit_card),
  MenuItem('Jadwal Khatam', Icons.calendar_today),
  MenuItem('Reward', Icons.card_giftcard),
  MenuItem('Laporan', Icons.pie_chart),
];
void onMenuClick(BuildContext context, String title) {
  switch (title) {
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
        MaterialPageRoute(builder: (context) => KhatamPage()),
      );
      break;
    case 'Donasi':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DonasiPage()),
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
        MaterialPageRoute(builder: (context) => ReportMain()),
      );
      break;
    default:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Menu $title belum ada aksi")));
  }
}

void onMenuClick2(BuildContext context, String title) {
  switch (title) {
    case 'Khotmul':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => KhotmulPage()),
      );
      break;
    case 'Donasi':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DonasiPage()),
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
        MaterialPageRoute(builder: (context) => ReportMain()),
      );
      break;
    default:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Menu $title belum ada aksi")));
  }
}
