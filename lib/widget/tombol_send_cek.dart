import 'package:flutter/material.dart';

class SendCheckButtons extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onCheckAll;
  final bool allChecked;

  const SendCheckButtons({
    super.key,
    required this.onSend,
    required this.onCheckAll,
    required this.allChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          ElevatedButton.icon(
            // kalau belum semua checked, tombol disable
            onPressed: allChecked ? onSend : null,
            icon: const Icon(Icons.send),
            label: const Text("Send"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onCheckAll,
            icon: Icon(allChecked ? Icons.clear_all : Icons.done_all),
            label: Text(allChecked ? "Clear All" : "Cek All"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
