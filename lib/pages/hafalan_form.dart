import 'package:flutter/material.dart';
import '../repositories/hafalan_repo.dart';

class HafalanForm extends StatefulWidget {
  final int assignmentId;

  const HafalanForm({required this.assignmentId});

  @override
  State<HafalanForm> createState() => _HafalanFormState();
}

class _HafalanFormState extends State<HafalanForm> {
  final fromController = TextEditingController();
  final toController = TextEditingController();

  bool loading = false;

  void submit() async {
    setState(() => loading = true);

    final success = await HafalanRepo().submit(
      assignmentId: widget.assignmentId,
      ayatFrom: int.parse(fromController.text),
      ayatTo: int.parse(toController.text),
    );

    setState(() => loading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Berhasil disimpan")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: fromController,
          decoration: InputDecoration(labelText: "Ayat From"),
        ),
        TextField(
          controller: toController,
          decoration: InputDecoration(labelText: "Ayat To"),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: loading ? null : submit,
          child: Text("Submit"),
        ),
      ],
    );
  }
}
