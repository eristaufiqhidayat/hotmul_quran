import 'package:flutter/material.dart';
import 'pages/login.dart';

//import 'pages/homepage.dart';
// import file login.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(MyApp());
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
      home: LoginPage(), // ✅ Scaffold berada di dalam MaterialApp
    );
  }
}
