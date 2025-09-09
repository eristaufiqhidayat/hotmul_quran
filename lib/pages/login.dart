// ignore_for_file: use_build_context_synchronously, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/register.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard.dart'; // Import halaman homepage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> login() async {
    setState(() => _loading = true);

    final response = await http.post(
      Uri.parse("${GlobalConst.url}/api/v1/login"), // Ganti dengan API kamu
      body: {
        "email": _emailController.text,
        "password": _passwordController.text,
      },
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await saveToken(
        data['access_token'],
        data['refresh_token'],
        data['name'],
        data['email'],
        data['anggota_id'].toString(),
        data['group_id'].toString(),
        data['daurah_id'].toString(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        //const SnackBar(content: Text("Login gagal, periksa kembali")),
        SnackBar(content: Text("${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text("Login"), backgroundColor: Colors.green),
      backgroundColor: Colors.green[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: 350,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green, // Warna border hijau
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Image.asset(
                  "assets/logo.png", // taruh logo kamu di assets
                  height: 120,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Majelis Khotmul Qur’an\nPusaka Ilahi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 32),

                // EMAIL FIELD
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PASSWORD FIELD
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // LOGIN BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : login,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
