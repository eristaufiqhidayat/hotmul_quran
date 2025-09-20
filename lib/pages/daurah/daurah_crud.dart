// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, sort_child_properties_last

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/custom_textfile.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:http/http.dart' as http;

class EditDaurahPage extends StatefulWidget {
  final Map<String, dynamic> anggota;

  const EditDaurahPage({super.key, required this.anggota});

  @override
  State<EditDaurahPage> createState() => _EditDaurahPageState();
}

class _EditDaurahPageState extends State<EditDaurahPage> {
  late TextEditingController group_id;
  late TextEditingController group_name;

  @override
  void initState() {
    super.initState();
    //print(widget.anggota);
    group_name = TextEditingController(text: widget.anggota['group_name']);
    group_id = TextEditingController(
      text: widget.anggota['group_id'].toString(),
    );
  }

  Future<void> saveDelete() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/daurah/${group_id.text}");

    final payload = {"group_id": group_id.text, "group_name": group_name.text};

    final response = await http.delete(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // penting
      },
      body: jsonEncode(payload), // jadi JSON
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal hapus data")));
    }
  }

  Future<void> saveEdit() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/daurah/${group_id.text}");

    final payload = {"group_id": group_id.text, "group_name": group_name.text};
    //print(payload);
    // ignore: unused_local_variable
    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // penting
      },
      body: jsonEncode(payload), // jadi JSON
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Data berhasil diperbarui")),
      );
      // ✅ kirim true biar parent tau harus refresh
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal simpan data")));
    }
  }

  Future<void> saveNew() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/daurah/");

    final payload = {"group_name": group_name.text};
    //print(payload);
    // ignore: unused_local_variable
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // penting
      },
      body: jsonEncode(payload), // jadi JSON
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(
        context,
        true,
      ); // ✅ kirim true biar parent tau harus refresh
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal simpan data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(statusAnggota);

    return Scaffold(
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Edit Anggota"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: group_id,
              label: "Daurah ID",
              icon: Icons.badge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: group_name,
              label: "Nama Daurah",
              icon: Icons.person,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.anggota['group_id'] != null) {
                        saveEdit();
                      } else {
                        saveNew();
                      }
                      //Navigator.pop(context, true);
                    },
                    child: () {
                      if (widget.anggota['group_id'] != null) {
                        return const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        );
                      } else {
                        return const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white),
                        );
                      }
                    }(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40), // tinggi tombol
                      backgroundColor: Colors.blue, // warna background tombol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // sudut agak melengkung
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: widget.anggota['group_id'] != null
                      ? ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Konfirmasi"),
                                  content: const Text(
                                    "Yakin ingin menghapus data ini?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Batal"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Hapus"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              saveDelete(); // baru eksekusi hapus kalau user pilih "Hapus"
                            }
                          },
                          child: const Text(
                            "Hapus",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
