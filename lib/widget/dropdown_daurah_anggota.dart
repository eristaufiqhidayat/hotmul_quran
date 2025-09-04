import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:http/http.dart' as http;

class daurahDropdown extends StatefulWidget {
  final void Function(Map<String, dynamic>?)? onChanged; // callback ke parent
  final int? value; // default selected value

  const daurahDropdown({super.key, this.onChanged, this.value});

  @override
  State<daurahDropdown> createState() => _daurahDropdownState();
}

class _daurahDropdownState extends State<daurahDropdown> {
  List<Map<String, dynamic>> groupUsers = [];
  Map<String, dynamic>? selectedUser;
  int? selectedGroupId;

  @override
  void initState() {
    super.initState();
    selectedGroupId = widget.value; // set default value kalau ada
    print("Default Daurah: $selectedUser");
    fetchGroupUsers();
  }

  Future<void> fetchGroupUsers() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/daurah");

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final data = body is Map<String, dynamic> && body.containsKey("data")
          ? body["data"]
          : body;

      setState(() {
        groupUsers = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return groupUsers.isEmpty
        ? const CircularProgressIndicator()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Group User",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                borderRadius: BorderRadius.circular(16),
                hint: const Text(
                  "Silakan pilih Daurah",
                  style: TextStyle(color: Colors.grey),
                ),
                value: selectedGroupId, // ✅ sekarang cocok
                dropdownColor: Colors.white,
                isExpanded: true,
                items: groupUsers.map((user) {
                  return DropdownMenuItem<int>(
                    value: user["group_id"], // ✅ hanya kirim group_id
                    child: Text(user["group_name"] ?? "No Name"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGroupId = value;
                  });
                  // ambil map lengkap berdasarkan group_id
                  final selectedMap = groupUsers.firstWhere(
                    (g) => g["group_id"] == value,
                    orElse: () => {},
                  );
                  widget.onChanged?.call(selectedMap);
                },
              ),
            ],
          );
  }
}
