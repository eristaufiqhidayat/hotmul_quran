import 'package:flutter/material.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const PrimaryAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green.shade900,
      elevation: 2,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: false, // <-- biar teks rata kiri
      iconTheme: const IconThemeData(color: Colors.white), // ikon back putih
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      title: titleWidget ?? Text(title ?? ''),
      actions: actions,
    );
  }
}
