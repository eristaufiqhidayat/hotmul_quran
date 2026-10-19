import 'package:flutter/material.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/pages/admin_monitoring_page.dart';
import 'package:hotmul_quran/pages/member_home_page.dart';
import 'package:hotmul_quran/pages/notification_page.dart';
import 'package:hotmul_quran/pages/setor_hafalan_page.dart';
import 'package:provider/provider.dart';

import 'package:hotmul_quran/providers/auth_provider.dart';
import 'package:hotmul_quran/service/http_override/http_override.dart';
import 'package:hotmul_quran/pages/login.dart';
import 'package:hotmul_quran/pages/dashboard.dart';
import 'package:hotmul_quran/pages/homepage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Hotmul Quran',
        theme: ThemeConfig.light(),
        // Batasi skala font sistem agar layout tidak overflow di HP dengan
        // ukuran font sangat besar.
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: child!,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const QuranApp(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const Dashboard(),
          '/homepage': (context) => const QuranApp(),
          '/setoran-hafalan': (context) => const SetoranHafalanPage(),
          '/beranda-hafalan': (context) => const MemberHomePage(),
          '/notifikasi': (context) => const NotificationPage(),
          '/monitoring': (context) => const AdminMonitoringPage(),
        },
      ),
    );
  }
}
