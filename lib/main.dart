import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/homepage.dart';
// import file login.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotmul Quran',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginPage(), // ✅ Scaffold berada di dalam MaterialApp
    );
  }
}
