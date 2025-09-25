import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/messege_model.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:http/http.dart' as http;
// import 'package:hotmul_quran/pages/messege/form_send.dart';

class MessageDetailPage extends StatefulWidget {
  final MessageUser messageUser;
  final String baseUrl = "${GlobalConst.url}/api/v1";

  const MessageDetailPage({super.key, required this.messageUser});

  @override
  State<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  bool _isLoading = false;
  bool _statusUpdated = false;

  Future<void> updateStatus(int id) async {
    if (_statusUpdated) return; // Hindari update berulang

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await getValidAccessToken();
      // Perbaiki URL yang salah (menggunakan > bukan ?)
      final response = await http.get(
        Uri.parse("${widget.baseUrl}/messages/updateStatus/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print("${widget.baseUrl}/messages/updateStatus/$id");
      print(response.body);
      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          _statusUpdated = true;
        });
      } else {
        throw Exception("Failed to update message status");
      }
    } catch (e) {
      print("Error updating status: $e");
      // Bisa ditambahkan snackbar untuk menampilkan error ke user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update message status")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Update status pesan saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateStatus(widget.messageUser.id);
    });
  }

  void dispose() {
    // if (_statusUpdated) {
    //   if (!mounted) {
    //     Navigator.pop(context, true); // kirim hasil ke halaman sebelumnya
    //   }
    // } else {
    //   if (mounted) {
    //     Navigator.pop(context, false);
    //   }
    // }
    // if (_statusUpdated) {
    //   Navigator.pop(context, true);
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.messageUser.message;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Message Detail",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade900,

        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      msg.content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
