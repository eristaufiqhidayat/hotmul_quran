import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/messege/inbox_icon.dart';
import 'package:hotmul_quran/pages/messege/inbox_messege.dart';
import 'package:hotmul_quran/model/messege_model.dart';
import 'package:hotmul_quran/service/messege_service.dart';
import 'package:hotmul_quran/widget/drawer.dart';

import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/model/modelMenu.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int? groupId; // nilai dari local
  bool isLoading = true;
  var user_id;
  var countUnread;
  // ignore: unused_field
  late Future<List<MessageUser>> _inboxFuture;
  @override
  void initState() {
    super.initState();
    _loadGroupId();
    _user_id();

    //_inboxFuture = MessageService().getInbox(user_id);
  }

  Future<void> _loadGroupId() async {
    final idString = await getGroup_id();
    //print(idString); // fungsi dari token_services.dart
    setState(() {
      groupId = int.tryParse(idString ?? "0"); // kalau null → 0
      isLoading = false;
    });
  }

  Future<void> _user_id() async {
    final idString = await getUser_id();
    user_id = int.tryParse(idString ?? "0"); // ✅ conv
    final unread = await getUnredCount(user_id);
    //print("Unread count $unread");
    // tunggu hasilnya
    setState(() {
      countUnread = unread; // simpan sebagai int
    });
    MessageService().getInbox(user_id).then((inboxList) {
      //for (var msg in inboxList) {
      //print("Message ID: ${msg.id}, is_read: ${msg.isRead}");
      //}
      setState(() {
        _inboxFuture = Future.value(inboxList);
      });
    });
  }

  Future<int> getUnredCount(int user_id) async {
    final count = await MessageService().getcountUnread(user_id);
    return count; // harus int
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // kasih default value 0 kalau null
    final gId = groupId ?? 0;

    // pilih menu berdasarkan groupId
    final items = gId == 1 ? menuItems : menuItems2;
    final onClick = gId == 1 ? onMenuClick : onMenuClick2;

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        actions: [
          InboxIcon(
            unreadCount: countUnread ?? 0, // ✅ default kalau null
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InboxPage(userId: user_id ?? 0),
                ),
              );
              if (result == true) {
                setState(() {
                  // panggil lagi API / refresh state dashboard
                  countUnread();
                });
              }
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => InboxPage(userId: user_id ?? 0),
              //   ), // ✅ default kalau null
              // );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/logo.png'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
        backgroundColor: const Color.fromARGB(255, 15, 99, 18),
        toolbarHeight: 100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return ElevatedButton(
              onPressed: () => onClick(context, item.title),
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
                  const SizedBox(height: 8),
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
