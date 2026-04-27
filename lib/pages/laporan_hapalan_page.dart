import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/laporan_hapalan_model.dart';
import 'package:hotmul_quran/service/laporan_hapalan_service.dart';

class LaporanHafalanPage extends StatefulWidget {
  const LaporanHafalanPage({super.key});

  @override
  State<LaporanHafalanPage> createState() => _LaporanHafalanPageState();
}

class _LaporanHafalanPageState extends State<LaporanHafalanPage> {
  List<LaporanHafalan> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await fetchLaporan();
    setState(() {
      data = result;
      isLoading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'done':
        return Colors.green;
      case 'late':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget buildProgress(int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: value / 100),
        Text("$value%"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Hafalan"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Nama")),
                  DataColumn(label: Text("Juz")),
                  DataColumn(label: Text("Progress")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Last Input")),
                ],
                rows: data.map((e) {
                  return DataRow(
                    cells: [
                      DataCell(Text(e.name)),
                      DataCell(Text("Juz ${e.juz}")),
                      DataCell(buildProgress(e.progress)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: getStatusColor(e.status),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            e.status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      DataCell(Text(e.lastInput)),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
