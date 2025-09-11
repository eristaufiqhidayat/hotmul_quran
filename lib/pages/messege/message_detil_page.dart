import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/messege_model.dart';
// import 'package:hotmul_quran/pages/messege/form_send.dart';

class MessageDetailPage extends StatelessWidget {
  final MessageUser messageUser;

  const MessageDetailPage({super.key, required this.messageUser});

  @override
  Widget build(BuildContext context) {
    final msg = messageUser.message;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Message Detail"),
        backgroundColor: Colors.green.shade900,
        actions: [
          // IconButton(
          //   tooltip: "Reply",
          //   icon: const Icon(Icons.reply),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => SendMessagePage(senderId: msg.senderId),
          //       ),
          //     );
          //   },
          // ),
          // IconButton(
          //   tooltip: "Forward",
          //   icon: const Icon(Icons.forward),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => SendMessagePage(senderId: 0),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "From: ${msg.sender?.name ?? 'Unknown'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  msg.content,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    msg.createdAt != null ? "📅 Sent: ${msg.createdAt}" : "",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: Colors.green.shade800,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => SendMessagePage(senderId: msg.senderId),
      //       ),
      //     );
      //   },
      //   icon: const Icon(Icons.reply),
      //   label: const Text("Reply"),
      // ),
    );
  }
}
