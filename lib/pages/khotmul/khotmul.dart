// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- Tambahkan Google Fonts
import 'package:hotmul_quran/const/global_const.dart';
//import 'package:hotmul_quran/pages/khotmul/khotmul_crud.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/pages/khotmul/listquran_perjuz.dart';
import 'package:hotmul_quran/widget/progress_bar_khotmul.dart';
//import 'package:hotmul_quran/widget/refreshNew.dart';
import 'package:hotmul_quran/widget/searchbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KhotmulPage extends StatefulWidget {
  const KhotmulPage({super.key});

  @override
  State<KhotmulPage> createState() => _KhotmulPageState();
}

class _KhotmulPageState extends State<KhotmulPage> {
  int currentPage = 1;
  int lastPage = 1;
  List<dynamic> anggota = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  var juzNumber = 1;
  int totalAyah = 20; // nanti bisa diganti sesuai data asli per juz
  Set<int> readAyahs = {};

  var anggota_id;
  var group_id;
  var daurah_id;

  Future<void> fetchDataGroup({int page = 1, String? search}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/khotmul?group_id=$daurah_id&page=$page&search=${search ?? ''}",
    );

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    //print(response.body);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        anggota = result['data'];
        currentPage = result['current_page'];
        lastPage = result['last_page'];
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchData({int page = 1, String? search}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/khotmul/anggota/$anggota_id?group_id=$daurah_id",
    );
    // print(
    //   "${GlobalConst.url}/api/v1/khotmul/anggota/$anggota_id?group_id=$daurah_id",
    // );
    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    //print("Khotmul ${response.body}");
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final List<dynamic> dataList = (result['data'] as List<dynamic>?) ?? [];
      setState(() {
        anggota = dataList;
      });
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadAnggotaId();
    await _loadGroupId();
    await _loadDaurahId();
    await fetchData();
  }

  Future<void> _loadAnggotaId() async {
    anggota_id = await getAnggota_id();
    if (mounted) setState(() {});
  }

  Future<void> _loadGroupId() async {
    group_id = await getGroup_id();
    if (mounted) setState(() {});
  }

  Future<void> _loadDaurahId() async {
    daurah_id = await getDaurah_id();
    if (mounted) setState(() {});
  }

  Future<void> loadReadAyahs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('readAyahs_${juzNumber}') ?? [];
    setState(() {
      readAyahs = saved.map((e) => int.parse(e)).toSet();
    });
  }

  double get progress {
    if (totalAyah == 0) return 0;
    return readAyahs.length / totalAyah;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50, // 🌿 Background lembut
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Khotmul Quran"),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Tombol Refresh + Add
          Row(
            children: [
              // ActionButtons(
              //   onRefresh: () => fetchData(page: currentPage),
              //   onNew: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => EditKhotmulPage(anggota: {}),
              //       ),
              //     ).then((updated) {
              //       if (updated == true) fetchData(page: currentPage);
              //     });
              //   },
              // ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: fetchData,
                icon: const Icon(Icons.assignment_ind, color: Colors.white),
                label: const Text(
                  "Me",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.pressed))
                      return Colors.red;
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.blue.shade900;
                    }
                    return Colors.blue.shade900;
                  }),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
              ),
              SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: fetchDataGroup,
                icon: const Icon(Icons.group, color: Colors.white),
                label: const Text(
                  "All",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.pressed))
                      return Colors.red;
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.blue.shade900;
                    }
                    return Colors.blue.shade900;
                  }),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SearchFieldWidget(
              controller: searchController,
              onSubmitted: (value) => fetchData(page: 1, search: value),
            ),
          ),

          // List Data
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: anggota.length,
                    itemBuilder: (context, index) {
                      final item = anggota[index];
                      MaterialColor warna;
                      IconData button;
                      item['status'] == "" ||
                              item['status'] == null ||
                              item['status'] == "send_no"
                          ? {warna = Colors.red, button = Icons.close}
                          : {warna = Colors.green, button = Icons.check};

                      return Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: warna,
                                child: Text(
                                  item['juz'] != null
                                      ? item['juz'].toString()
                                      : '-',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                "Juz ${item['juz'] ?? ''}",
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      anggota_id ==
                                          item['anggota_id'].toString()
                                      ? 20
                                      : 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      anggota_id ==
                                          item['anggota_id'].toString()
                                      ? Colors.green
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(
                                            2,
                                          ), // Lebar kolom label
                                          1: FixedColumnWidth(
                                            20,
                                          ), // Lebar kolom tanda :
                                          2: FlexColumnWidth(
                                            3,
                                          ), // Lebar kolom value
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              Text(
                                                "Nama",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                ":",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              anggota_id ==
                                                      item['anggota_id']
                                                          .toString()
                                                  ? Text(
                                                      "${item['name'] ?? '-'}",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 20,
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    )
                                                  : Text(
                                                      "${item['name'] ?? '-'}",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                    ),
                                            ],
                                          ),
                                          TableRow(
                                            children: [
                                              Text(
                                                "Group",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                ":",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                "${item['group_id'] ?? '-'}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: [
                                              Text(
                                                "Periode",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                ":",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                "${item['periode'] ?? '-'}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Text(
                                        warna == Colors.green
                                            ? "Status : Sudah Khatam"
                                            : "Status : Belum Khatam",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: warna,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: warna == Colors.green
                                                ? [
                                                    Colors.greenAccent,
                                                    Colors.green,
                                                  ]
                                                : [
                                                    Colors.redAccent,
                                                    Colors.red,
                                                  ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: warna.withOpacity(0.6),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          button,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing:
                                  anggota_id == item['anggota_id'].toString()
                                  ? PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.green,
                                      ),
                                      onSelected: (value) async {
                                        if (value == 'khatam') {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => JuzAyahPage(
                                                juzNumber: item["juz"],
                                                khotmulId: item['id'],
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            await fetchData(page: currentPage);
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'khatam',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.record_voice_over,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text("Add Khatam"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          ProgressBarKhotmul(
                            progress: progress,
                            total: totalAyah,
                            done: readAyahs.length,
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                  ),
          ),
        ],
      ),
    );
  }
}
