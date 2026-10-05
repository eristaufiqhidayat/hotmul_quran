// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, sort_child_properties_last

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/custom_textfile.dart';
import 'package:hotmul_quran/widget/datetimepicker.dart';
import 'package:hotmul_quran/service/api_client.dart';

class EditRewardPage extends StatefulWidget {
  final Map<String, dynamic> anggota;

  const EditRewardPage({super.key, required this.anggota});

  @override
  State<EditRewardPage> createState() => _EditRewardPageState();
}

class _EditRewardPageState extends State<EditRewardPage> {
  late TextEditingController id;
  late TextEditingController rp;
  late TextEditingController tanggal;
  String? tanggalForDb;
  List<Map<String, dynamic>> users = [];
  int? selectedUser;
  var group_user;
  var name;
  List<dynamic> groups = [];
  String? selectedUserId;
  bool isLoadingGroups = true;
  Future<void> _loadGroupUser() async {
    group_user = await getRole();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    id = TextEditingController(text: widget.anggota['id']?.toString() ?? '');
    rp = TextEditingController(text: widget.anggota['rp']?.toString() ?? '');
    tanggal = TextEditingController(
      text: widget.anggota['tanggal']?.toString() ?? '',
    );

    // simpan user_id yg lama sebagai string (bisa null)
    selectedUserId = widget.anggota['user_id']?.toString();

    // ambil list groups untuk dropdown
    fetchGroups();
    fetchUsers();
    _loadGroupUser();
  }

  Future<void> fetchUsers() async {
    final response = await ApiClient.get("${GlobalConst.url}/api/v1/anggota");
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // cek apakah ada "data" (Laravel paginate)
      final data = body is Map<String, dynamic> && body.containsKey("data")
          ? body["data"]
          : body;

      setState(() {
        users = List<Map<String, dynamic>>.from(data);
      });

      debugPrint("Users loaded: $users");
    } else {
      debugPrint("Failed to load users: ${response.body}");
    }
  }

  Future<void> fetchGroups() async {
    if (!mounted) return;

    setState(() => isLoadingGroups = true);

    try {
      final response = await ApiClient.get(
        "${GlobalConst.url}/api/v1/anggota2",
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        List<dynamic> list;
        if (body is Map && body['data'] is List) {
          list = body['data'];
        } else if (body is List) {
          list = body;
        } else {
          list = [];
        }

        if (!mounted) return;

        setState(() {
          groups = list;

          if (selectedUserId != null) {
            final exists = groups.any(
              (g) => g['user_id']?.toString() == selectedUserId,
            );
            if (!exists) {
              selectedUserId = groups.isNotEmpty
                  ? groups[0]['user_id']?.toString()
                  : null;
            }
          } else {
            selectedUserId = groups.isNotEmpty
                ? groups[0]['user_id']?.toString()
                : null;
          }
        });
      } else {
        throw Exception("Gagal load group");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (!mounted) return;
      setState(() => isLoadingGroups = false);
    }
  }

  String _groupLabel(dynamic item) {
    //print(item);
    if (item == null) return '';
    return (item['name'] ?? item['group_name'] ?? item.toString()).toString();
  }

  Future<void> saveDelete() async {
    try {
      final response = await ApiClient.delete(
        "${GlobalConst.url}/api/v1/reward/${id.text}",
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        throw Exception("Gagal hapus");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> saveEdit() async {
    if (selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih user/group terlebih dahulu")),
      );
      return;
    }

    final payload = {
      "anggota_id": selectedUserId,
      "rp": rp.text,
      "tanggal": tanggal.text,
    };
    print("Payload untuk update: $payload");
    try {
      final response = await ApiClient.put(
        "${GlobalConst.url}/api/v1/reward/${id.text}",
        body: payload, // ✅ WAJIB pakai body:
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? "Gagal simpan data")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> saveNew() async {
    if (selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih user/group terlebih dahulu")),
      );
      return;
    }

    final payload = {
      "anggota_id": selectedUserId, // ⬅️ samakan dengan backend (penting!)
      "rp": rp.text,
      "tanggal": tanggal.text,
    };

    try {
      final response = await ApiClient.post(
        "${GlobalConst.url}/api/v1/reward",
        body: payload, // ✅ WAJIB pakai body:
      );

      debugPrint('saveNew resp: ${response.statusCode} ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? "Gagal simpan data")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    //int? selectedUserId;
    return Scaffold(
      appBar: PrimaryAppBar(title: "Edit Reward"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(controller: id, label: "id", icon: Icons.badge),
            const SizedBox(height: 16),

            //Dropdown: tunjukkan loading saat ambil groups
            isLoadingGroups
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Memuat daftar group...'),
                      ],
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value:
                        selectedUserId != null &&
                            groups.any(
                              (g) =>
                                  g['anggota_id']?.toString() == selectedUserId,
                            )
                        ? selectedUserId
                        : null,
                    decoration: const InputDecoration(
                      labelText: "Pilih User / Group",
                      border: OutlineInputBorder(),
                    ),
                    items: groups
                        .where(
                          (item) => item['anggota_id'] != null,
                        ) // ⬅️ filter null
                        .map<DropdownMenuItem<String>>((item) {
                          final val = item['anggota_id'].toString();
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(_groupLabel(item)),
                          );
                        })
                        .toList(),
                    onChanged: group_user != "admin"
                        ? null
                        : (value) {
                            setState(() {
                              selectedUserId = value;
                            });
                          },
                  ),
            const SizedBox(height: 24),
            CustomTextField(controller: rp, label: "Rp", icon: Icons.person),
            const SizedBox(height: 16),
            DatePickerField(
              label: "Tanggal",
              controller: tanggal, // isinya langsung yyyy-MM-dd
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.anggota["id"] != null) {
                        saveEdit();
                      } else {
                        saveNew();
                      }
                    },
                    child: () {
                      if (widget.anggota["id"] != null) {
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
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: widget.anggota["id"] != null
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
