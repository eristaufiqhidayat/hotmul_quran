import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/doa.dart';
import 'package:hotmul_quran/pages/home.dart';
//import 'package:hotmul_quran/pages/profile.dart';
import 'package:hotmul_quran/pages/surah_list.dart';
import 'package:hotmul_quran/pages/surah_detil_page.dart';
import 'package:hotmul_quran/widget/drawer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const KhotmilQuranPage(),
    const SurahListPage(),
    const SurahDetailPage(number: 1, name: 'Al-Fatihah'),
    const DoaApp(),
    //const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text('Qur\'an App')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Surat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            label: 'Qur\'an',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pan_tool_alt_outlined),
            label: 'Do\'a',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person_outline),
          //   label: 'Profile',
          // ),
        ],
      ),
    );
  }
}
