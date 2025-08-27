import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 15, 99, 18)),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ...menuItems.map(
            (item) => ListTile(
              leading: Icon(item.icon, color: Color.fromARGB(255, 15, 99, 18)),
              title: Text(item.title),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                onItemSelected(item.title);
              },
            ),
          ),
        ],
      ),
    );
  }
}
