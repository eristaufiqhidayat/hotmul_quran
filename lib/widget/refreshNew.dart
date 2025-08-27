// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onNew;

  const ActionButtons({
    super.key,
    required this.onRefresh,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: onRefresh,
            child: const Icon(Icons.refresh, color: Colors.white),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.pressed)) return Colors.red;
                if (states.contains(MaterialState.hovered)) {
                  return Colors.blue.shade900;
                }
                return Colors.blue.shade900;
              }),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
          SizedBox(width: 2),
          ElevatedButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "New",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.pressed)) return Colors.red;
                if (states.contains(MaterialState.hovered)) {
                  return Colors.blue.shade900;
                }
                return Colors.blue.shade900;
              }),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
