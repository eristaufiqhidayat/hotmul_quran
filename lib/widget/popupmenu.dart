import 'package:flutter/material.dart';

class CustomPopupMenu<T> extends StatelessWidget {
  final T value;
  final void Function(T) onView;
  final void Function(T) onEdit;
  final void Function(T) onDelete;

  const CustomPopupMenu({
    Key? key,
    required this.value,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String choice) {
        switch (choice) {
          case 'view':
            onView(value);
            break;
          case 'edit':
            onEdit(value);
            break;
          case 'delete':
            onDelete(value);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'view', child: Text('View')),
        const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
        const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
