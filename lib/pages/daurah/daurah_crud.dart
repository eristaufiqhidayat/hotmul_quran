import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/custom_textfile.dart';
import 'package:hotmul_quran/widget/drawer.dart';

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

    group_name = TextEditingController(text: widget.anggota['group_name']);
    group_id = TextEditingController(
      text: widget.anggota['group_id'].toString(),
    );
  }

  /// DELETE
  Future<void> saveDelete() async {
    final url = "${GlobalConst.url}/api/v1/daurah/${group_id.text}";

    final response = await ApiClient.delete(url);

    if (response.statusCode == 200) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal hapus data")));
    }
  }

  /// UPDATE
  Future<void> saveEdit() async {
    final url = "${GlobalConst.url}/api/v1/daurah/${group_id.text}";

    final response = await ApiClient.put(
      url,
      body: {"group_id": group_id.text, "group_name": group_name.text},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Data berhasil diperbarui")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal simpan data")));
    }
  }

  /// CREATE
  Future<void> saveNew() async {
    final url = "${GlobalConst.url}/api/v1/daurah/";

    final response = await ApiClient.post(
      url,
      body: {"group_name": group_name.text},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal simpan data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Edit Anggota"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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

            /// BUTTON ACTION
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.anggota['group_id'] != null ? "Update" : "Simpan",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                /// DELETE BUTTON
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
                              saveDelete();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size.fromHeight(40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Hapus",
                            style: TextStyle(color: Colors.white),
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
