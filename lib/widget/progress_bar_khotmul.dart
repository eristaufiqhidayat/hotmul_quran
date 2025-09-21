import 'package:flutter/material.dart';

class ProgressBarKhotmul extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final int total;
  final int done;
  final String status;

  const ProgressBarKhotmul({
    super.key,
    required this.progress,
    required this.total,
    required this.done,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Progress Khatam",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("$done / $total"),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              color: this.status == "send_voice" ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),

            const SizedBox(height: 6),

            // Persentase
            this.status == "send_voice"
                ? Text(
                    "${(progress * 100).toStringAsFixed(1)}% selesai dan sudah lapor",
                  )
                : Text(
                    "${(progress * 100).toStringAsFixed(1)}% selesai dan belum lapor",
                  ),
          ],
        ),
      ),
    );
  }
}
