import 'package:flutter/material.dart';
import 'package:hotmul_quran/pages/setor_hafalan_page.dart';
import 'package:provider/provider.dart';

import 'package:hotmul_quran/providers/auth_provider.dart';
import 'package:hotmul_quran/service/token_services.dart';

import 'package:hotmul_quran/pages/splashscreen.dart';
import 'package:hotmul_quran/pages/login.dart';
import 'package:hotmul_quran/pages/dashboard.dart';
import 'package:hotmul_quran/pages/homepage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 🔐 cek login
  Future<bool> checkLogin() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Hotmul Quran',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Poppins', // kalau pakai font lokal
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => QuranApp(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const Dashboard(),
          '/homepage': (context) => const QuranApp(),
          '/setoran-hafalan': (context) => const SetoranHafalanPage(),
        },
      ),
    );
  }
}
