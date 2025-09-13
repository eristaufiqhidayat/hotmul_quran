// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- Tambahkan Google Fonts
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/khotmulperiode/khotmulperiode_crud.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/pages/khotmul/listquran_perjuz.dart';
import 'package:hotmul_quran/widget/refreshNew.dart';
import 'package:hotmul_quran/widget/searchbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hotmul_quran/service/token_services.dart';

class KhotmulPeriodePage extends StatefulWidget {
  const KhotmulPeriodePage({super.key});

  @override
  State<KhotmulPeriodePage> createState() => _KhotmulPeriodePageState();
}

class _KhotmulPeriodePageState extends State<KhotmulPeriodePage> {
  int currentPage = 1;
  int lastPage = 1;
  List<dynamic> anggota = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  var anggota_id;
  var group_id;
  var daurah_id;

  Future<void> fetchData({int page = 1, String? search}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/khotmulperiode?group_id=$daurah_id&page=$page&search=${search ?? ''}",
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

  @override
  void initState() {
    super.initState();
    fetchData();
    _loadAnggotaId();
    _loadGroupId();
    _loadDaurahId();
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

  Widget buildPagination() {
    List<Widget> pages = [];

    for (int i = 1; i <= lastPage; i++) {
      if (i == 1 ||
          i == lastPage ||
          (i >= currentPage - 2 && i <= currentPage + 2)) {
        pages.add(
          InkWell(
            onTap: () => fetchData(page: i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: i == currentPage ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  if (i == currentPage)
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                "$i",
                style: GoogleFonts.poppins(
                  fontWeight: i == currentPage
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: i == currentPage ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      } else if (i == currentPage - 3 || i == currentPage + 3) {
        pages.add(Text("...", style: GoogleFonts.poppins()));
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: pages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50, // 🌿 Background lembut
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Khotmulperiode Quran"),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Tombol Refresh + Add
          ActionButtons(
            onRefresh: () => fetchData(page: currentPage),
            onNew: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditKhotmulperiodePage(anggota: {}),
                ),
              ).then((updated) {
                if (updated == true) fetchData(page: currentPage);
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

                      return Card(
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
                                  anggota_id == item['anggota_id'].toString()
                                  ? 20
                                  : 16,
                              fontWeight: FontWeight.w600,
                              color: anggota_id == item['anggota_id'].toString()
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
                                                  item['anggota_id'].toString()
                                              ? Text(
                                                  "${item['name'] ?? '-'}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              : Text(
                                                  "${item['name'] ?? '-'}",
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
                                crossAxisAlignment: WrapCrossAlignment.center,
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
                                            ? [Colors.greenAccent, Colors.green]
                                            : [Colors.redAccent, Colors.red],
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
                          trailing: anggota_id == item['anggota_id'].toString()
                              ? PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.green,
                                  ),
                                  onSelected: (value) async {
                                    // if (value == 'khatam') {
                                    //   final result = await Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //       builder: (context) => JuzAyahPage(
                                    //         juzNumber: item["juz"],
                                    //         khotmulperiodeId: item['id'],
                                    //       ),
                                    //     ),
                                    //   );
                                    //   if (result == true) {
                                    //     await fetchData(page: currentPage);
                                    //   }
                                    // }
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
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                  ),
          ),

          // Pagination
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: buildPagination(),
          ),
        ],
      ),
    );
  }
}
