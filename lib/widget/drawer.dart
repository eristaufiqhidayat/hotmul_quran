import 'package:flutter/material.dart';
import 'package:hotmul_quran/service/token_services.dart';

class MenuItem {
  final String title;
  final IconData icon;
  MenuItem(this.title, this.icon);
}

typedef MenuItemCallback = void Function(String title);

class AppDrawer extends StatelessWidget {
  final List<MenuItem> menuItems;
  final MenuItemCallback onItemSelected;

  const AppDrawer({
    super.key,
    required this.menuItems,
    required this.onItemSelected,
  });

  Future<Map<String, String>> getUserFromLocal() async {
    final name = await getUser(); // asumsikan getUser() async
    final email = await getEmail(); // asumsikan getEmail() async
    final anggota_id = await getAnggota_id(); // asumsikan getAnggotaId() async
    final group_id = await getGroup_id(); // asumsikan getGroupId() async
    return {'name': ?name, 'email': ?email};
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, String>>(
        future: getUserFromLocal(),
        builder: (context, snapshot) {
          String name = snapshot.data?['name'] ?? '';
          String email = snapshot.data?['email'] ?? '';
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
                          "Group id ${group_id}",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ...menuItems.map(
                (item) => ListTile(
                  leading: Icon(
                    item.icon,
                    color: Color.fromARGB(255, 15, 99, 18),
                  ),
                  title: Text(item.title),
                  onTap: () {
                    Navigator.pop(context);
                    onItemSelected(item.title);
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
