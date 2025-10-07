import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:http/http.dart' as http;

class GroupUserDropdown extends StatefulWidget {
  final void Function(Map<String, dynamic>?)? onChanged; // callback ke parent
  final int? value; // default selected value

  const GroupUserDropdown({super.key, this.onChanged, this.value});

  @override
  State<GroupUserDropdown> createState() => _GroupUserDropdownState();
}

class _GroupUserDropdownState extends State<GroupUserDropdown> {
  List<Map<String, dynamic>> groupUsers = [];
  int? selectedUser;

  @override
  void initState() {
    super.initState();
    selectedUser = widget.value; // set default value kalau ada
    print("Widget initial value:  ${widget.value}");
    fetchGroupUsers();
  }

  Future<void> fetchGroupUsers() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/groupUser");

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

      final List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(
        data,
      );

      setState(() {
        groupUsers = users;
        //print("Widget Selected users:  $selectedUser");
      });

      //debugPrint("Users loaded: $groupUsers");
    } else {
      debugPrint("Failed to load users: ${response.body}");
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
                  "Silakan pilih group user",
                  style: TextStyle(color: Colors.grey),
                ),
                value: widget.value,
                dropdownColor: Colors.white,
                isExpanded: true,
                items: groupUsers.map((user) {
                  return DropdownMenuItem<int>(
                    value: user["id"], // ✅ hanya kirim user id
                    child: Text(user["name"] ?? "No Name"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUser = value;
                  });
                  final selectedMap = groupUsers.firstWhere(
                    (g) => g["id"] == value,
                    orElse: () => {},
                  );
                  widget.onChanged?.call(selectedMap); // kirim value ke parent
                },
              ),
            ],
          );
  }
}
