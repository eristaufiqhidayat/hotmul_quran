import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/dashboard.dart';
import 'package:hotmul_quran/pages/homepage.dart';
import 'package:hotmul_quran/pages/login.dart';
import 'package:hotmul_quran/service/token_services.dart';

class MenuDrawer {
  final String title;
  final IconData icon;
  MenuDrawer(this.title, this.icon);
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String name = '';
  String email = '';
  String groupId = '';
  String anggotaId = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final n = await getUser();
    final e = await getEmail();
    final g = await getGroup_id();
    final a = await getAnggota_id();

    setState(() {
      name = n ?? '';
      email = e ?? '';
      groupId = g?.toString() ?? '';
      anggotaId = a?.toString() ?? '';
    });
  }

  Future<void> onDrawerClick(BuildContext context, String title) async {
    switch (title) {
      case 'Logout':
        await logout();
        break;
      case 'Login':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
      case 'Home Page':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuranApp()),
        );
      case 'Dashboard':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu $title belum ada aksi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan menu berdasarkan anggotaId
    final List<MenuDrawer> menuDrawers = (anggotaId.isNotEmpty)
        ? [
            MenuDrawer('Home Page', Icons.person),
            MenuDrawer('Dashboard', Icons.dashboard),
            MenuDrawer('Logout', Icons.logout),
          ]
        : [
            MenuDrawer('Home Page', Icons.person),
            MenuDrawer('Login', Icons.login),
          ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 15, 99, 18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/logo.png'),
                  radius: 30,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : "Tamu",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email.isNotEmpty ? email : "-",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      groupId.isNotEmpty ? "Group id $groupId" : "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...menuDrawers.map(
            (item) => ListTile(
              leading: Icon(
                item.icon,
                color: const Color.fromARGB(255, 15, 99, 18),
              ),
              title: Text(item.title),
              onTap: () async {
                Navigator.pop(context);
                await onDrawerClick(context, item.title);
              },
            ),
          ),
        ],
      ),
    );
  }
}
