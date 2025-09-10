import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/messege_model.dart';
import 'package:hotmul_quran/pages/messege/message_detil_page.dart';
import 'package:hotmul_quran/service/messege_service.dart';

class InboxPage extends StatefulWidget {
  final int userId;
  const InboxPage({super.key, required this.userId});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late Future<List<MessageUser>> _inboxFuture;

  @override
  void initState() {
    super.initState();
    _inboxFuture = MessageService().getInbox(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox"),
        backgroundColor: Colors.green.shade900,
      ),
      body: FutureBuilder<List<MessageUser>>(
        future: _inboxFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final messages = snapshot.data ?? [];

          // Kosong
          if (messages.isEmpty) {
            return const Center(child: Text("No messages"));
          }

          // List pesan
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msgUser = messages[index];
              final msg = msgUser.message;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    msgUser.isRead
                        ? Icons.mail_outline
                        : Icons.mark_email_unread,
                    color: msgUser.isRead ? Colors.grey : Colors.red,
                  ),
                  title: Text(
                    msg.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text("From: ${msg.sender?.name ?? 'Unknown'}"),
                  trailing: Text(
                    msg.createdAt != null
                        ? msg.createdAt!.substring(0, 10) // ambil yyyy-mm-dd
                        : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    // buka detail pesan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageDetailPage(messageUser: msgUser),
                      ),
                    ).then((_) {
                      // refresh inbox kalau balik dari detail
                      setState(() {
                        _inboxFuture = MessageService().getInbox(widget.userId);
                      });
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
