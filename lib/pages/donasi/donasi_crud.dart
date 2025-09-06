// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, sort_child_properties_last

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/custom_textfile.dart';
import 'package:hotmul_quran/widget/datetimepicker.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:http/http.dart' as http;

class EditDonasiPage extends StatefulWidget {
  final Map<String, dynamic> anggota;

  const EditDonasiPage({super.key, required this.anggota});

  @override
  State<EditDonasiPage> createState() => _EditDonasiPageState();
}

class _EditDonasiPageState extends State<EditDonasiPage> {
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
    group_user = await getGroup_id();
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
    //fetchUsers();
    _loadGroupUser();
  }

  Future<void> fetchUsers() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/anggota");

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
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
    if (!mounted) return; // amanin sebelum masuk
    setState(() {
      isLoadingGroups = true;
    });

    try {
      final token = await getToken();
      final url = Uri.parse("${GlobalConst.url}/api/v1/anggota2");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        List<dynamic> list;
        if (body is Map && body.containsKey('data') && body['data'] is List) {
          list = body['data'];
        } else if (body is List) {
          list = body;
        } else {
          list = [];
        }

        if (!mounted) return; // <--- tambah ini
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
        if (!mounted) return; // <--- tambah ini
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat daftar group')),
        );
      }
    } catch (e) {
      debugPrint('fetchGroups error: $e');
      if (!mounted) return; // <--- tambah ini
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saat memuat daftar group')),
      );
    } finally {
      if (!mounted) return; // <--- tambah ini
      setState(() {
        isLoadingGroups = false;
      });
    }
  }

  String _groupLabel(dynamic item) {
    //print(item);
    if (item == null) return '';
    return (item['name'] ?? item['group_name'] ?? item.toString()).toString();
  }

  Future<void> saveDelete() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/donasi/${id.text}");

    final payload = {"id": id.text};

    final response = await http.delete(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

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

  Future<void> saveEdit() async {
    if (selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih user/group terlebih dahulu")),
      );
      return;
    }

    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/donasi/${id.text}");

    final payload = {
      "user_id": selectedUserId,
      "rp": rp.text,
      "tanggal": tanggal.text,
    };
    //print(payload);
    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );
    //print(response.body);
    //debugPrint('saveEdit resp: ${response.statusCode} ${response.body}');
    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal simpan data")));
    }
  }

  Future<void> saveNew() async {
    if (selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih user/group terlebih dahulu")),
      );
      return;
    }

    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/donasi/");

    final payload = {
      "user_id": selectedUserId,
      "rp": rp.text,
      "tanggal": tanggal.text,
    };

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    debugPrint('saveNew resp: ${response.statusCode} ${response.body}');
    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal simpan new data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    //int? selectedUserId;
    return Scaffold(
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Edit Donasi"),
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
                        groups.any(
                          (g) => g['user_id']?.toString() == selectedUserId,
                        )
                        ? selectedUserId
                        : null,
                    decoration: const InputDecoration(
                      labelText: "Pilih User / Group",
                      border: OutlineInputBorder(),
                    ),
                    items: groups.map<DropdownMenuItem<String>>((item) {
                      final val = item['user_id']?.toString();
                      name = item;
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(_groupLabel(item)),
                      );
                    }).toList(),
                    onChanged: group_user != "1"
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
