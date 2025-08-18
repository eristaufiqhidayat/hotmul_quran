import 'package:flutter/material.dart';
import 'pages/login.dart'; // import file login.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Majelis Khotmul',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<MenuItem> menuItems = [
    MenuItem('Anggota', Icons.person),
    MenuItem('Dauroh', Icons.menu),
    MenuItem('Khatam', Icons.check_circle),
    MenuItem('Donasi', Icons.credit_card),
    MenuItem('Jadwal Khatam', Icons.calendar_today),
    MenuItem('Reward', Icons.card_giftcard),
    MenuItem('Laporan', Icons.pie_chart),
    MenuItem('Login', Icons.login), // Tambah menu Login
  ];

  void _onMenuClick(BuildContext context, String title) {
    switch (title) {
      case 'Login':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        break;

      case 'Anggota':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu Anggota diklik")));
        break;
      case 'Dauroh':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu Dauroh diklik")));
        break;
      case 'Khatam':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu Khatam diklik")));
        break;
      case 'Donasi':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu Donasi diklik")));
        break;
      case 'Jadwal Khatam':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu Jadwal Khatam diklik")));
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
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/logo.png'), // masukkan logo
              radius: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Dashboard', style: TextStyle(fontSize: 14)),
                  Text(
                    "MAJELIS KHOTMUL QUR'AN PUSAKA ILAHI",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            CircleAvatar(child: Text('A'), backgroundColor: Colors.orange),
          ],
        ),
        backgroundColor: Colors.green,
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

class MenuItem {
  final String title;
  final IconData icon;

  MenuItem(this.title, this.icon);
}
