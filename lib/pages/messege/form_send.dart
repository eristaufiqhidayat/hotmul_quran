import 'package:flutter/material.dart';
import 'package:hotmul_quran/service/messege_service.dart';

class SendMessagePage extends StatefulWidget {
  final int senderId; // id user yg login
  const SendMessagePage({super.key, required this.senderId});

  @override
  State<SendMessagePage> createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final _contentController = TextEditingController();
  String targetType = "all"; // default
  final _targetIdController =
      TextEditingController(); // kalau target user/group

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Message"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown target type
            DropdownButtonFormField<String>(
              value: targetType,
              decoration: const InputDecoration(labelText: "Target Type"),
              items: const [
                DropdownMenuItem(value: "all", child: Text("All")),
                DropdownMenuItem(value: "user", child: Text("User")),
                DropdownMenuItem(value: "group", child: Text("Group")),
              ],
              onChanged: (val) {
                setState(() {
                  targetType = val!;
                });
              },
            ),
            const SizedBox(height: 12),

            // Target ID kalau user/group
            if (targetType != "all")
              TextField(
                controller: _targetIdController,
                decoration: InputDecoration(
                  labelText: targetType == "user" ? "User ID" : "Group ID",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 12),

            // Isi pesan
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final success = await MessageService().sendMessage(
                  senderId: widget.senderId,
                  targetType: targetType,
                  targetId: targetType == "all"
                      ? null
                      : int.tryParse(_targetIdController.text),
                  content: _contentController.text,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Message sent successfully")),
                  );
                  _contentController.clear();
                  _targetIdController.clear();
                  setState(() {
                    targetType = "all";
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to send message")),
                  );
                }
              },
              icon: const Icon(Icons.send),
              label: const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}
