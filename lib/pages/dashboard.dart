import 'package:flutter/material.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/model/modelMenu.dart';
import 'package:hotmul_quran/pages/messege/inbox_icon.dart';
import 'package:hotmul_quran/pages/messege/inbox_messege.dart';
import 'package:hotmul_quran/service/messege_service.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/drawer.dart';

/// Menu utama setelah login. Isi menu mengikuti `users.role` dari API
/// (`admin` → kelola grup & monitoring, `member` → lapor hafalan).
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isLoading = true;
  String role = 'member';
  String name = '';
  int userId = 0;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final r = await getRole();
    final n = await getUser();
    final id = int.tryParse(await getUser_id() ?? '') ?? 0;
    if (!mounted) return;
    setState(() {
      role = (r == null || r.isEmpty) ? 'member' : r;
      name = n ?? '';
      userId = id;
      isLoading = false;
    });
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    if (userId == 0) return;
    try {
      final count = await MessageService().getcountUnread(userId);
      if (mounted) setState(() => unreadCount = count);
    } catch (_) {
      // badge pesan bersifat opsional
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final admin = role == 'admin';
    final items = admin ? menuItems : menuItems2;
    final onClick = admin ? onMenuClick : onMenuClick2;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        actions: [
          InboxIcon(
            unreadCount: unreadCount,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InboxPage(userId: userId)),
              );
              _loadUnread();
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/logo.png'),
              radius: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MAJELIS KHOTMUL QUR'AN",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "PUSAKA ILAHI",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: ThemeConfig.primaryDark,
        toolbarHeight: 80,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: ThemeConfig.primaryDark,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                name.isEmpty ? 'Sahabat Qur\'an' : name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                admin ? 'Admin kelompok' : 'Anggota',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onClick(context, item.title),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 34,
                          color: ThemeConfig.primaryDark,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
