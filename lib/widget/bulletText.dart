import 'package:flutter/material.dart';

class BulletText extends StatelessWidget {
  final String text;
  final Color color;

  const BulletText({Key? key, required this.text, this.color = Colors.black})
    : super(key: key);

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
