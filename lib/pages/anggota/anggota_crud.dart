// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, sort_child_properties_last, unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/custom_textfile.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/widget/dropdown_daurah_anggota.dart';
import 'package:hotmul_quran/widget/dropdown_groupUser.dart';

class EditAnggotaPage extends StatefulWidget {
  final Map<String, dynamic> anggota;
  final int? daurah_id;
  const EditAnggotaPage({super.key, required this.anggota, this.daurah_id});

  @override
  State<EditAnggotaPage> createState() => _EditAnggotaPageState();
}

class _EditAnggotaPageState extends State<EditAnggotaPage> {
  late TextEditingController nameController;
  late TextEditingController idController;
  late TextEditingController groupController;
  late TextEditingController userName;
  late TextEditingController email;
  late TextEditingController userPass;
  bool cekDataPro = false;
  Map<String, dynamic> statusAnggota = {};
  late MaterialColor warnaUserPanel;
  List<Map<String, dynamic>> groupUsers = [];
  int? selectedUser;
  Map<String, dynamic>? daurah;
  String? group_id;
  bool isChangePassword = false;

  @override
  void initState() {
    super.initState();
    print(widget.anggota['name']);
    _initData();
    //print(widget.anggota);
    nameController = TextEditingController(text: widget.anggota['name']);
    idController = TextEditingController(
      text: widget.anggota['id'] != null ? widget.anggota['id'].toString() : "",
    );
    groupController = TextEditingController(
      text: widget.anggota['group_id']?.toString() ?? "",
    );
    userName = TextEditingController(text: widget.anggota['name']);
    userPass = TextEditingController(text: "password");
    email = TextEditingController(text: widget.anggota['email']);
    cekData(anggota_id: widget.anggota['user_id'] ?? 1);
    //pri
    if (widget.daurah_id != null) {
      daurah = {
        "daurah_id": widget.daurah_id,
        "daurah_name": "Daurah ${widget.daurah_id}",
      };
    } else {
      daurah = {
        "daurah_id": widget.anggota['daurah_id'],
        "daurah_name": "Daurah ${widget.anggota['daurah_id']}",
      };
    }
    //print(daurah);
  }

  Future<void> checkGroup({String? anggota_id}) async {
    if (!mounted || anggota_id == null) return;

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final response = await ApiClient.post(
      "${GlobalConst.url}/api/v1/cekAnggota?anggota_id=$anggota_id",
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      final data = result['data'];

      if (data != null && data['group_id'] != null) {
        setState(() {
          selectedUser = data['group_id'];
        });
      } else {
        setState(() {
          selectedUser = null;
        });
      }
    } else {
      print("Error response: ${response.body}");
    }
  }

  Future<void> _initData() async {
    final userId = widget.anggota['user_id'];

    if (userId != null) {
      checkGroup(anggota_id: userId.toString());
    }
    //print("Group id dari token: $group_id");
  }

  Future<void> saveDelete() async {
    final response = await ApiClient.delete(
      "${GlobalConst.url}/api/v1/anggota/${idController.text}",
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal update data")));
    }
  }

  Future<void> saveEdit() async {
    updateUserAnggota();
  }

  Future<void> addUserAnggota() async {
    final payload = {
      "anggota_id": idController.text,
      "name": nameController.text,
      "email": userName.text,
      "password": userPass.text,
    };

    //print(token);
    final response = await ApiClient.post(
      "${GlobalConst.url}/api/v1/addUserAnggota",
      body: payload, // jadi JSON
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal update User Login")));
    }
  }

  Future<void> addAnggota() async {
    final payload = {
      "name": nameController.text,
      "daurah_id": widget.daurah_id,
    };
    print("Add Anggota $payload");
    final response = await ApiClient.post(
      "${GlobalConst.url}/api/v1/anggota",
      body: payload,
    );
    print(response.body);
    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal update User Login")));
    }
  }

  Future<void> updateUserAnggota() async {
    if (!mounted) return;
    final payload = {
      "group_id": selectedUser,
      "id": idController.text,
      "name": nameController.text,
      "email": email.text,
      "daurah_id": daurah?["group_id"],
    };

    // hanya kirim password kalau dicentang
    if (isChangePassword && userPass.text.isNotEmpty) {
      payload["password"] = userPass.text;
    }

    print("updateUserAnggota ${payload}");
    //print(token);
    if (!mounted) return;
    final response = await ApiClient.put(
      "${GlobalConst.url}/api/v1/updateUser/${idController.text}",
      body: payload,
    );
    print(response.body);
    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal update User Login")));
    }
  }

  Future<void> cekData({required int anggota_id}) async {
    setState(() => cekDataPro = true);
    final response = await ApiClient.post(
      "${GlobalConst.url}/api/v1/cekAnggota?anggota_id=$anggota_id",
    );
    //print(response.body);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      statusAnggota = result['data'] ?? {};
    }

    setState(() => cekDataPro = false);
  }

  @override
  Widget build(BuildContext context) {
    warnaUserPanel = Colors.blue;
    return Scaffold(
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Edit Anggota"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: idController,
                label: "Anggota ID",
                icon: Icons.badge,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: nameController,
                label: "Nama Lengkap",
                icon: Icons.person,
              ),
              daurahDropdown(
                value: daurah?["daurah_id"] as int?, // default value
                onChanged: (value) {
                  setState(() => daurah = value);
                  debugPrint(
                    "Parent menerima: ${value?["daurah_id"]} - ${value?["daurah_name"]}",
                  );
                },
              ),

              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                  color: warnaUserPanel, // background aktif
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      GroupUserDropdown(
                        value: widget.anggota['group_id'], // default value
                        onChanged: (value) {
                          setState(() => selectedUser = value?['id'] as int?);
                        },
                      ),

                      const SizedBox(height: 2),
                      const Text(
                        "Email",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ), // biar teks kelihatan
                      ),
                      TextField(
                        controller: email,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true, // aktifkan warna background
                          fillColor: Colors.white, // biar kotak input putih
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isChangePassword,
                            onChanged: (value) {
                              setState(() {
                                isChangePassword = value ?? false;
                                if (!isChangePassword) {
                                  userPass
                                      .clear(); // reset kalau tidak jadi ganti
                                }
                              });
                            },
                          ),
                          const Text(
                            "Ganti Password",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        enabled: isChangePassword,
                        controller: userPass,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        obscureText: true, // password disembunyikan
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: idController.text.trim().isEmpty
                          ? addAnggota
                          : saveEdit,
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          color: Colors.white,
                        ), // biar tulisan putih
                      ),
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
                    child: ElevatedButton(
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
                                  onPressed: () => Navigator.pop(context, true),
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
