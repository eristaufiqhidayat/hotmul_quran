// ignore_for_file: file_names

import 'package:flutter/material.dart';

class BulletText extends StatelessWidget {
  final String text;
  final Color color;

  const BulletText({super.key, required this.text, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 16)), // bullet
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 14)),
        ),
      ],
    );
  }
}
