import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/anggota/group_hotmul.dart';
import 'package:hotmul_quran/pages/daurah/group_daurah.dart';
import 'package:hotmul_quran/pages/donasi/donasi.dart';
import 'package:hotmul_quran/pages/jadwal/jadwal.dart';
import 'package:hotmul_quran/pages/khatam/khatam.dart';
import 'package:hotmul_quran/pages/login.dart';
import 'package:hotmul_quran/service/token_services.dart';

class MenuDrawer {
  final String title;
  final IconData icon;
  MenuDrawer(this.title, this.icon);
}

final List<MenuDrawer> menuDrawers = [
  MenuDrawer('Home Page', Icons.person),
  MenuDrawer('Logout', Icons.login),
];
void onDrawerClick(BuildContext context, String title) {
  switch (title) {
    case 'Logout':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      break;

    default:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Menu $title belum ada aksi")));
  }
}

class AppDrawer extends StatelessWidget {
  Future<Map<String, String>> getUserFromLocal() async {
    final name = await getUser(); // asumsikan getUser() async
    final email = await getEmail(); // asumsikan getEmail() async
    final anggota_id = await getAnggota_id(); // asumsikan getAnggotaId() async
    final group_id = await getGroup_id(); // asumsikan getGroupId() async
    return {
      'name': ?name,
      'email': ?email,
      'group_id': ?group_id,
      'anggota_id': ?anggota_id,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, String>>(
        future: getUserFromLocal(),
        builder: (context, snapshot) {
          String name = snapshot.data?['name'] ?? '';
          String email = snapshot.data?['email'] ?? '';
          // ignore: non_constant_identifier_names
          String group_id = snapshot.data?['group_id'] ?? '';

          return ListView(
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
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/logo.png'),
                      radius: 30,
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          "Group id $group_id",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
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
                    color: Color.fromARGB(255, 15, 99, 18),
                  ),
                  title: Text(item.title),
                  onTap: () {
                    Navigator.pop(context);
                    onDrawerClick(context, item.title);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
