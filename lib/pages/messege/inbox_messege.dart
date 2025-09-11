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
  var msgUser;

  @override
  void initState() {
    super.initState();
    _inboxFuture = MessageService().getInbox(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Inbox"),
        backgroundColor: Colors.green.shade900,
        centerTitle: true,
      ),
      body: FutureBuilder<List<MessageUser>>(
        future: _inboxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return const Center(
              child: Text(
                "📭 No messages",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              msgUser = messages[index];
              final msg = msgUser.message;

              return Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Icon(
                    msgUser.isRead
                        ? Icons.mail_outline
                        : Icons.mark_email_unread,
                    color: msgUser.isRead ? Colors.grey : Colors.green.shade800,
                    size: 30,
                  ),
                  title: Text(
                    msg.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: msgUser.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "From: ${msg.sender?.name ?? 'Unknown'}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  // trailing: Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     IconButton(
                  //       tooltip: "Reply",
                  //       icon: const Icon(Icons.reply, color: Colors.green),
                  //       onPressed: () {
                  //         // TODO: fungsi reply
                  //       },
                  //     ),
                  //     IconButton(
                  //       tooltip: "Forward",
                  //       icon: const Icon(Icons.forward, color: Colors.green),
                  //       onPressed: () {
                  //         // TODO: fungsi forward
                  //       },
                  //     ),
                  //   ],
                  // ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageDetailPage(messageUser: msgUser),
                      ),
                    ).then((_) {
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => MessageDetailPage(messageUser: msgUser),
      //       ),
      //     );
      //   },
      //   backgroundColor: Colors.green.shade800,
      //   icon: const Icon(Icons.create),
      //   label: const Text("New Message"),
      // ),
    );
  }
}
