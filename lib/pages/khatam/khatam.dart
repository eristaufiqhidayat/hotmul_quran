import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/model/daurah_model.dart';
import 'package:hotmul_quran/model/laporan_hapalan_model.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/service/daurah_service.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/dropdown_periode_widget.dart';

class AdminUpdateKhatamPage extends StatefulWidget {
  const AdminUpdateKhatamPage({super.key});

  @override
  State<AdminUpdateKhatamPage> createState() => _AdminUpdateKhatamPageState();
}

class _AdminUpdateKhatamPageState extends State<AdminUpdateKhatamPage> {
  bool isLoading = true;

  //List daurahList = [];
  List<Daurah> daurahList = [];
  List<LaporanHafalan> anggotaList = [];

  Daurah? selectedDaurah;
  LaporanHafalan? selectedAnggota;

  String selectedStatus = "active";
  int? selectedDaurahId;
  Map<String, dynamic>? selectedPeriode;

  @override
  void initState() {
    super.initState();

    print('Masuk ke class: $runtimeType');

    loadDaurah();
  }

  /// ===============================
  /// LOAD DAURAH
  /// ===============================
  Future<void> loadDaurah() async {
    try {
      final res = await ApiService().fetchDaurah();
      ;
      if (res.isNotEmpty) {
        selectedDaurahId = res.first.id;
        //loadLaporan();
      }
      // final body = ApiClient.decode(res);

      setState(() {
        daurahList = res;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  /// ===============================
  /// LOAD ANGGOTA BERDASARKAN DAURAH
  /// ===============================
  Future<void> loadAnggota(int groupId) async {
    try {
      setState(() {
        isLoading = true;
      });

      // final res = await ApiClient.get(
      //   "${GlobalConst.url}/api/v1/laporan-hafalan/$groupId",
      // );
      final res = await ApiService().fetchLaporanByDaurah(
        selectedDaurahId!,
        groupId != null
            ? groupId
            : selectedPeriode != null
            ? selectedPeriode!['periode_khotmul']
            : 0,
      );
      //print(res.body);
      //final body = ApiClient.decode(res);

      setState(() {
        // anggotaList = body['data'] ?? [];
        anggotaList = res;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  /// ===============================
  /// UPDATE STATUS
  /// ===============================
  Future<void> updateStatus() async {
    try {
      final res = await ApiClient.put(
        "${GlobalConst.url}/api/v1/khatam/update-status",
        body: {
          "assignment_id": selectedAnggota!.assignmentId,
          "status": selectedStatus,
        },
      );
      print(
        'Assignment ID: ${selectedAnggota!.assignmentId}, Status: $selectedStatus',
      );
      print('Update Status Response: ${res.body}');
      final body = ApiClient.decode(res);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(body['message'] ?? 'Berhasil update')),
      );
    } catch (e) {
      print(e);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'done':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'active':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Update Status Khatam"),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===============================
                  /// DROPDOWN DAURAH
                  /// ===============================
                  const Text(
                    "Pilih Daurah",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField(
                    value: selectedDaurah,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: daurahList.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.name ?? '-'),
                      );
                    }).toList(),

                    onChanged: (value) async {
                      if (value == null) return;

                      final item = value as Daurah;

                      setState(() {
                        selectedDaurah = item;
                        selectedAnggota = null;
                      });

                      await loadAnggota(item.id);
                    },
                  ),

                  const SizedBox(height: 20),

                  /// ===============================
                  /// DROPDOWN ANGGOTA
                  /// ===============================
                  const Text(
                    "Pilih Periode Khatam",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),
                  if (selectedDaurahId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: PeriodeDaurahDropdown(
                        groupId: selectedDaurahId!,

                        onChanged: (value) {
                          setState(() {
                            selectedPeriode = value;
                          });

                          debugPrint(
                            "Periode dipilih: "
                            "${value['periode_group']}"
                            "$selectedDaurahId",
                          );
                          //loadLaporan();
                          /*
            hasil:
            {
              id: 1,
              name: Group DAUROH 1,
              periode_group: 165,
              periode_khotmul: 1
            }
            */
                        },
                      ),
                    ),
                  SizedBox(height: 12),
                  const Text(
                    "Pilih Anggota",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField(
                    value: selectedAnggota,

                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: anggotaList.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text("${e.name} - Juz ${e.juz}"),
                      );
                    }).toList(),

                    onChanged: (value) {
                      if (value == null) return;

                      final item = value as LaporanHafalan;

                      setState(() {
                        selectedAnggota = item;

                        selectedStatus = item.status ?? 'active';
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// ===============================
                  /// STATUS CARD
                  /// ===============================
                  if (selectedAnggota != null)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedAnggota!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text("Juz ${selectedAnggota!.juz}"),

                            // Text(
                            //   "Ayat ${selectedAnggota.ayat_from} - ${selectedAnggota.ayat_to}",
                            // ),
                            const SizedBox(height: 15),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(selectedStatus),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                selectedStatus.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// ===============================
                            /// DROPDOWN STATUS
                            /// ===============================
                            DropdownButtonFormField(
                              value: selectedStatus,
                              decoration: InputDecoration(
                                labelText: "Status",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              items: const [
                                DropdownMenuItem(
                                  value: "active",
                                  child: Text("ACTIVE"),
                                ),
                                DropdownMenuItem(
                                  value: "done",
                                  child: Text("DONE"),
                                ),
                                DropdownMenuItem(
                                  value: "expired",
                                  child: Text("EXPIRED"),
                                ),
                                DropdownMenuItem(
                                  value: "late",
                                  child: Text("LATE"),
                                ),
                              ],

                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value.toString();
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),

                                onPressed: () async {
                                  await updateStatus();
                                },

                                child: const Text(
                                  "UPDATE STATUS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
