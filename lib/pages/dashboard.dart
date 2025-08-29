// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/anggota/group_hotmul.dart';
import 'package:hotmul_quran/pages/daurah/group_daurah.dart';
import 'package:hotmul_quran/pages/donasi/donasi.dart';
import 'package:hotmul_quran/pages/jadwal/jadwal.dart';
import 'package:hotmul_quran/pages/khatam/khatam.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'login.dart'; // Import halaman login// Import MenuItem from drawer.dart

class Dashboard extends StatelessWidget {
  final List<MenuItem> menuItems = [
    MenuItem('Anggota', Icons.person),
    MenuItem('Dauroh', Icons.menu),
    MenuItem('Khatam', Icons.check_circle),
    MenuItem('Donasi', Icons.credit_card),
    MenuItem('Jadwal Khatam', Icons.calendar_today),
    MenuItem('Reward', Icons.card_giftcard),
    MenuItem('Laporan', Icons.pie_chart),
    MenuItem('Logout', Icons.login),
  ];

  void _onMenuClick(BuildContext context, String title) {
    switch (title) {
      case 'Logout':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu Reward diklik")));
        break;
      case 'Laporan':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu Laporan diklik")));
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu $title belum ada aksi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        menuItems: menuItems,
        onItemSelected: (title) => _onMenuClick(context, title),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/logo.png'),
              radius: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "MAJELIS KHOTMUL QUR'AN",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "PUSAKA ILAHI",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 15, 99, 18),
        toolbarHeight: 100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return ElevatedButton(
              onPressed: () => _onMenuClick(context, item.title),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade900,
                shadowColor: Colors.grey.withOpacity(0.5),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 40),
                  SizedBox(height: 8),
                  Text(item.title, textAlign: TextAlign.center),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
