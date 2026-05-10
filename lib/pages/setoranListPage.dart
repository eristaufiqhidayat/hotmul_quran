import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';

class SetoranListPage extends StatefulWidget {
  const SetoranListPage({super.key});

  @override
  State<SetoranListPage> createState() => _SetoranListPageState();
}

class _SetoranListPageState extends State<SetoranListPage> {
  List data = [];
  bool isLoading = true;
  bool isMeSelected = true;
  int? groupId;
  String groupName = "-";
  int? periodeGroup;

  var currentUserId;
  @override
  void initState() {
    super.initState();

    loadData();
    _user_id();
  }

  List get filteredData {
    if (isMeSelected) {
      return data.where((e) => e['id'] == currentUserId).toList();
    } else {
      return data; // semua group
    }
  }

  Future<void> _user_id() async {
    final idString = await getUser_id();
    currentUserId = int.tryParse(idString ?? "0"); // ✅ conv
    print("Current User ID: $currentUserId");
  }

  Future<void> loadData() async {
    final res = await ApiClient.get("${GlobalConst.url}/api/v1/hafalan/today");
    final body = ApiClient.decode(res);

    print("LOAD SETORAN: ${res.body}");

    setState(() {
      data = body['data'] ?? [];
      groupName = body['group_name'] ?? '-';
      groupId = body['group_id'] ?? 0;
      periodeGroup = body['periode'] ?? 0;

      isLoading = false;
    });
  }

  /// 🔥 WARNA BERDASARKAN PROGRESS
  Color getColor(int totalAyat, int targetAyat) {
    if (totalAyat == 0) {
      return Colors.red;
    } else if (totalAyat < targetAyat) {
      return Colors.orange;
    } else {
      return Colors.green;
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

  /// 🔥 ICON BERDASARKAN STATUS
  IconData getIcon(int totalAyat, int targetAyat) {
    if (totalAyat == 0) {
      return Icons.close;
    } else if (totalAyat < targetAyat) {
      return Icons.warning;
    } else {
      return Icons.check;
    }
  }

  /// 🔥 HITUNG PERSEN
  double getProgress(int totalAyat, int targetAyat) {
    if (targetAyat == 0) return 0;
    return totalAyat / targetAyat;
  }

  @override
  Widget build(BuildContext context) {
    print("Current User ID: $currentUserId");
    return Scaffold(
      appBar: AppBarCustom(title: "Setoran Hafalan"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// 🔥 CARD INFO GROUP
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          /// ICON
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.group, color: Colors.green),
                          ),

                          const SizedBox(width: 12),

                          /// TEXT INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Group ID: ${groupId ?? '-'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  groupName,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Text(
                                  "Periode: ${periodeGroup ?? 0}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// 🔥 BUTTON TOGGLE
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        /// 🔥 BUTTON ME
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isMeSelected = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isMeSelected
                                    ? Colors.green[700]
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "Me",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// 🔥 BUTTON GROUP
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isMeSelected = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isMeSelected
                                    ? Colors.green[700]
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "Groups",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// 🔥 LIST DATA
                Expanded(
                  child: filteredData.isEmpty
                      ? const Center(child: Text("Tidak ada data"))
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, i) {
                            final item = filteredData[i];
                            print(
                              "Total Ayat: ${item['target_ayat']}, Total Setoran: ${item['total_ayat']}",
                            );
                            final totalAyat = item['total_ayat'] ?? 0;
                            final targetAyat = item['target_ayat'] ?? 0;
                            final progress = getProgress(totalAyat, targetAyat);
                            final percent = (progress * 100).toStringAsFixed(0);
                            final isAllowed =
                                item['id'] == currentUserId &&
                                (item['status_assignment'] == 'active' ||
                                    item['status_assignment'] == 'done');
                            return Card(
                              color: isAllowed
                                  ? Colors.lightGreenAccent
                                  : Colors.grey[200],
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: ListTile(
                                onTap: () async {
                                  if (isAllowed) {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      '/setoran-hafalan',
                                      arguments: {
                                        "target_ayat": item['target_ayat'],
                                        "juz": item['juz'],
                                      },
                                    );

                                    if (result == true) loadData();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Data ini tidak bisa diakses oleh user lain atau sudah expired",
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },

                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['name'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(
                                          item['status_assignment'],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (item['status_assignment'] ?? '-')
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "$percent%",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: getColor(totalAyat, targetAyat),
                                      ),
                                    ),
                                  ],
                                ),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text("Juz ${item['juz'] ?? '-'}"),
                                    Text(
                                      "Ayat ${item['ayat_from']} - ${item['ayat_to']}",
                                    ),
                                    Text("Progress: $totalAyat / $targetAyat"),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation(
                                        getColor(totalAyat, targetAyat),
                                      ),
                                    ),
                                  ],
                                ),

                                leading: CircleAvatar(
                                  backgroundColor: getColor(
                                    totalAyat,
                                    targetAyat,
                                  ),
                                  child: Icon(
                                    getIcon(totalAyat, targetAyat),
                                    color: Colors.white,
                                  ),
                                ),

                                trailing: Checkbox(
                                  value: totalAyat >= targetAyat,
                                  onChanged: null,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
