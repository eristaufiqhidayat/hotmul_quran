import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';

class SetoranHafalanPage extends StatefulWidget {
  const SetoranHafalanPage({super.key});

  @override
  State<SetoranHafalanPage> createState() => _SetoranHafalanPageState();
}

class _SetoranHafalanPageState extends State<SetoranHafalanPage> {
  final _formKey = GlobalKey<FormState>();

  int? assignmentId;
  int juz = 0;

  final ayatFromController = TextEditingController();
  final ayatToController = TextEditingController();
  final catatanController = TextEditingController();

  bool isLoading = true;
  bool isSubmit = false;

  @override
  void initState() {
    super.initState();
    loadAssignment();
  }

  Future<void> loadAssignment() async {
    final response = await ApiClient.get(
      "${GlobalConst.url}/api/v1/assignment-active",
    );

    print("ASSIGNMENT RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      setState(() {
        isLoading = false;
        assignmentId = null;
      });

      return;
    }

    final body = jsonDecode(response.body);

    setState(() {
      assignmentId = body['assignment_id'];
      juz = body['juz'];
      isLoading = false;
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmit = true);

    final response = await ApiClient.post(
      "${GlobalConst.url}/api/hafalan",
      body: {
        "assignment_id": assignmentId.toString(),
        "ayat_from": ayatFromController.text,
        "ayat_to": ayatToController.text,
        "keterangan": catatanController.text,
      },
    );

    setState(() => isSubmit = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Setoran berhasil")));

      ayatFromController.clear();
      ayatToController.clear();
      catatanController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal kirim setoran")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Setoran Hafalan"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Juz $juz",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: ayatFromController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Ayat Dari",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Wajib diisi" : null,
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: ayatToController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Ayat Sampai",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Wajib diisi" : null,
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: catatanController,
                      decoration: const InputDecoration(
                        labelText: "Catatan",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmit ? null : submit,
                        child: isSubmit
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Kirim Setoran"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
