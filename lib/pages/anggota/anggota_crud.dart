// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, sort_child_properties_last, unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/bulletText.dart';
import 'package:hotmul_quran/widget/custom_textfile.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/widget/dropdown_daurah_anggota.dart';
import 'package:hotmul_quran/widget/dropdown_groupUser.dart';
import 'package:http/http.dart' as http;

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
  late TextEditingController userPass;
  bool cekDataPro = false;
  Map<String, dynamic> statusAnggota = {};
  late MaterialColor warnaUserPanel;
  List<Map<String, dynamic>> groupUsers = [];
  Map<String, dynamic>? selectedUser;
  Map<String, dynamic>? daurah;

  @override
  void initState() {
    super.initState();
    //print(widget.anggota);
    nameController = TextEditingController(text: widget.anggota['name']);
    idController = TextEditingController(
      text: widget.anggota['user_id'] != null
          ? widget.anggota['user_id'].toString()
          : "",
    );
    groupController = TextEditingController(
      text: widget.anggota['group_id'].toString(),
    );
    userName = TextEditingController(text: widget.anggota['name']);
    userPass = TextEditingController(text: "password");
    cekData(anggota_id: widget.anggota['user_id'] ?? 1);
    //pri
    if (widget.daurah_id != null) {
      daurah = {
        "group_id": widget.daurah_id,
        "group_name": "Daurah ${widget.daurah_id}",
      };
    } else {
      daurah = {
        "group_id": widget.anggota['group_id'],
        "group_name": "Daurah ${widget.anggota['group_id']}",
      };
    }
    print(daurah);
    selectedUser = {
      "id": widget.anggota['group_id'],
      "name": widget.anggota['group_name'] ?? "Tidak diketahui",
    };
  }

  Future<void> saveDelete() async {
    final token = await getToken();
    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/anggota/${idController.text}",
    );

    final payload = {
      "user_id": idController.text,
      "name": nameController.text,
      "group_id": daurah?["group_id"].toString(),
    };

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
      ).showSnackBar(const SnackBar(content: Text("Gagal update data")));
    }
  }

  Future<void> saveEdit() async {
    final token = await getToken();
    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/anggota/${idController.text}",
    );

    final payload = {
      "user_id": idController.text,
      "name": nameController.text,
      "group_id": daurah?["group_id"].toString(), // dari dropdown
    };
    print("Save edit $payload");
    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // penting
      },
      body: jsonEncode(payload), // jadi JSON
    );
    print(response.body);
    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      if (userName.text.isNotEmpty &&
          userPass.text.isNotEmpty &&
          statusAnggota['email'] == null) {
        addUserAnggota();
      } else {
        updateUserAnggota();
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal update data")));
    }
  }

  Future<void> addUserAnggota() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/addUserAnggota");

    final payload = {
      "anggota_id": idController.text,
      "name": nameController.text,
      "email": userName.text,
      "password": userPass.text,
    };
    //print(payload);
    //print(token);
    final response = await http.post(
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
      ).showSnackBar(const SnackBar(content: Text("Gagal update User Login")));
    }
  }

  Future<void> addAnggota() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/anggota");

    final payload = {
      "name": nameController.text,
      "group_id": widget.daurah_id.toString(),
    };
    print("Add Anggota $payload");
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // penting
      },
      body: jsonEncode(payload), // jadi JSON
    );
    print(response.statusCode);
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
    final token = await getToken();
    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/updateUser/${statusAnggota["user_id"]}",
    );

    final payload = {
      "group_id": selectedUser?["id"].toString(),
      "anggota_id": idController.text,
      "name": nameController.text,
      "email": userName.text,
      "password": userPass.text,
    };
    //print("updateUserAnggota ${payload}");
    //print(token);
    if (!mounted) return;
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
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal update User Login")));
    }
  }

  Future<void> cekData({required int anggota_id}) async {
    setState(() => cekDataPro = true);
    final token = await getToken(); // Ambil token dari SharedPreferences
    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/cekAnggota?anggota_id=$anggota_id",
    );
    final response = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
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
    //print(selectedUser);
    if (statusAnggota.isEmpty) {
      warnaUserPanel = Colors.red;
      userName.text = "";
      userPass.text = "";
    } else {
      warnaUserPanel = Colors.blue;
      userName.text = statusAnggota['email'] ?? "";
      userPass.text = statusAnggota['password'] ?? "";
    }
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
              const SizedBox(height: 16),
              daurahDropdown(
                value: daurah?["group_id"] as int?, // default value
                onChanged: (value) {
                  setState(() => daurah = value);
                  debugPrint(
                    "Parent menerima: ${value?["group_id"]} - ${value?["group_name"]}",
                  );
                },
              ),
              CustomTextField(
                controller: groupController,
                label: "Daurah ID",
                icon: Icons.group,
                keyboardType: TextInputType.number,
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
                        value: selectedUser, // default value
                        onChanged: (value) {
                          setState(() => selectedUser = value);
                          debugPrint(
                            "Parent menerima: ${value?["id"]} - ${value?["name"]}",
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Username",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ), // biar teks kelihatan
                      ),
                      TextField(
                        controller: userName,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true, // aktifkan warna background
                          fillColor: Colors.white, // biar kotak input putih
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
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
              BulletText(
                text:
                    "Warna panel biru berarti anggota sudah memiliki user login",
                color: Colors.blue.shade900,
              ),

              BulletText(
                text:
                    "Warna panel merah berarti anggota belum memiliki user login",
                color: Colors.red.shade900,
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
