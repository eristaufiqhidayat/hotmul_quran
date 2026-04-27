import 'package:flutter/material.dart';
import '../repositories/assignment_repo.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final res = await AssignmentRepo().getToday();

    setState(() {
      data = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return const Center(child: Text("Tidak ada data"));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: Text("Juz ${data!['juz_number']}"),
              subtitle: Text("Deadline: ${data!['end_date']}"),
            ),
          ),
        ],
      ),
    );
  }
}
