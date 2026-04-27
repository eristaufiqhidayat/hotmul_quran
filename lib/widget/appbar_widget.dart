import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? leading;
  final bool showBack; // ✅ kontrol back arrow
  final String routeName;

  const AppBarCustom({
    super.key,
    this.title = "Phase 3",
    this.leading,
    this.showBack = true, // ✅ default: TIDAK ADA back arrow
    this.routeName = "",
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeConfig.greenlogo,
      automaticallyImplyLeading: false, // ⬅️ penting
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: ThemeConfig.Font),
        ),
      ),

      // ✅ back arrow hanya muncul kalau diminta
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null,

      actions: leading,
    );
  }

  // static Widget cartIcon(BuildContext context) {
  //   return Consumer<CartProvider>(
  //     builder: (context, cart, _) {
  //       return Stack(
  //         clipBehavior: Clip.none,
  //         children: [
  //           IconButton(
  //             icon: const Icon(Icons.shopping_cart_outlined),
  //             onPressed: () {
  //               Navigator.pushNamed(context, '/cart');
  //             },
  //           ),
  //           if (cart.totalItems > 0)
  //             Positioned(
  //               right: 6,
  //               top: 6,
  //               child: Container(
  //                 padding: const EdgeInsets.all(4),
  //                 decoration: const BoxDecoration(
  //                   color: Colors.red,
  //                   shape: BoxShape.circle,
  //                 ),
  //                 constraints: const BoxConstraints(
  //                   minWidth: 18,
  //                   minHeight: 18,
  //                 ),
  //                 child: Text(
  //                   cart.totalItems.toString(),
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 10,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ),
  //             ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
