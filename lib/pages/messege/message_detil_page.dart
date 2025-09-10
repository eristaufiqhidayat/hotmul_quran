import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/messege_model.dart';
import 'package:hotmul_quran/pages/messege/form_send.dart';

class MessageDetailPage extends StatelessWidget {
  final MessageUser messageUser;

  const MessageDetailPage({super.key, required this.messageUser});

  @override
  Widget build(BuildContext context) {
    final msg = messageUser.message;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Detail"),
        backgroundColor: Colors.green.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "From: ${msg.sender?.name ?? 'Unknown'}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(msg.content, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              msg.createdAt != null ? "Sent: ${msg.createdAt}" : "",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SendMessagePage(senderId: 16),
                  ),
                );
              },
              icon: Icon(Icons.message_sharp),
            ),
          ],
        ),
      ),
    );
  }
}
