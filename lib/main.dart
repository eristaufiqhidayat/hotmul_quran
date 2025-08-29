import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/splashscreen.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Hotmul Quran',
      theme: ThemeData(primarySwatch: Colors.green),

      // ✅ Gunakan route
      initialRoute: '/',
      routes: {
        '/': (context) => AnimatedSplashScreen(),
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => Dashboard(),
      },
    );
  }
}
