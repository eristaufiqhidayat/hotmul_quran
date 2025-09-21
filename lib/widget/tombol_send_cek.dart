import 'package:flutter/material.dart';

class SendCheckButtons extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSend;
  final VoidCallback onCheckAll;
  final bool allChecked;

  const SendCheckButtons({
    super.key,
    required this.onClose,
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
          ElevatedButton(
            // kalau belum semua checked, tombol disable
            //onPressed: allChecked ? onSend : null,
            onPressed: allChecked ? onSend : null,
            child: const Icon(Icons.send),
            //label: const Text(""),
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
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              onClose();
            },
            //label: Text(""),
            child: const Icon(Icons.close),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
