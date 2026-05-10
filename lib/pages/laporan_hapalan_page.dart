import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/daurah_model.dart';
import 'package:hotmul_quran/model/laporan_hapalan_model.dart';
import 'package:hotmul_quran/service/daurah_service.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';

class LaporanHafalanPage extends StatefulWidget {
  const LaporanHafalanPage({super.key});

  @override
  State<LaporanHafalanPage> createState() => _LaporanHafalanPageState();
}

class _LaporanHafalanPageState extends State<LaporanHafalanPage> {
  List<LaporanHafalan> data = [];
  List<Daurah> daurahList = [];

  bool isLoading = true;

  int? selectedDaurahId;

  @override
  void initState() {
    super.initState();
    loadDaurah();
  }

  Future<void> loadDaurah() async {
    try {
      final result = await ApiService().fetchDaurah();

      setState(() {
        daurahList = result;
      });

      if (result.isNotEmpty) {
        selectedDaurahId = result.first.id;
        loadLaporan();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadLaporan() async {
    if (selectedDaurahId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService().fetchLaporanByDaurah(selectedDaurahId!);

      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
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
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: value / 100, minHeight: 8),
          const SizedBox(height: 4),
          Text("$value%"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Laporan Hafalan"),
      body: Column(
        children: [
          /// DROPDOWN DAURAH
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int>(
              value: selectedDaurahId,
              decoration: InputDecoration(
                labelText: "Pilih Daurah",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: daurahList.map((e) {
                return DropdownMenuItem<int>(value: e.id, child: Text(e.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDaurahId = value;
                });

                loadLaporan();
              },
            ),
          ),

          /// TABLE
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                ? const Center(child: Text("Data tidak ada"))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.green.shade100,
                        ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(e.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    e.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              DataCell(Text(e.lastInput)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
