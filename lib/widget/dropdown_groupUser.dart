import 'package:flutter/material.dart';

class RoleDropdown extends StatefulWidget {
  final void Function(String?)? onChanged;
  final String? value;

  const RoleDropdown({super.key, this.onChanged, this.value});

  @override
  State<RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<RoleDropdown> {
  final List<String> roles = ['admin', 'member'];
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Role",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          borderRadius: BorderRadius.circular(12),
          hint: const Text("Silakan pilih role"),
          value: roles.contains(selectedRole) ? selectedRole : null,
          items: roles.map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedRole = value;
            });
            widget.onChanged?.call(value);
          },
        ),
      ],
    );
  }
}
