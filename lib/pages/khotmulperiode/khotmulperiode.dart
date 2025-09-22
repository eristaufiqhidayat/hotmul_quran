// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart'; // <--- Tambahkan Google Fonts
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/khotmulperiode/khotmulperiode_crud.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/pages/khotmulperiode/tableVertikalKhotmul.dart';
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

  @override
  void initState() {
    super.initState();
    initLoad();
  }

  Future<void> initLoad() async {
    await fetchData();
    await Daurah_id(); // pastikan daurah_id sudah ada
  }

  Future<String?> Daurah_id() async {
    daurah_id = await getDaurah_id();
    print(daurah_id);
    return null;
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
      "${GlobalConst.url}/api/v1/khotmulPeriode?group_id=$daurah_id&page=$page&search=${search ?? ''}",
    );

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        anggota = (result['data'] as List?) ?? [];
        currentPage = result['current_page'] ?? 1;
        lastPage = result['last_page'] ?? 1;
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchSync({int page = 1, String? search}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final url = Uri.parse("${GlobalConst.url}/api/v1/khotmulPeriodeSync");

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    print(url);
    print(response.body);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        anggota = (result['data'] as List?) ?? [];
        currentPage = result['current_page'] ?? 1;
        lastPage = result['last_page'] ?? 1;
        fetchData(page: currentPage, search: "");
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> periodeCreate({required int daurah_id}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/khotmulPeriodeCreate?group_id=$daurah_id",
    );

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    print(response.body);
    await fetchData(page: currentPage);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50, // 🌿 Background lembut
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Khotmulperiode Quran"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: VerticalDataTableKhotmul(
          isLoading: isLoading,
          onRefresh: fetchData,
          onSearch: (value) => fetchData(page: 1, search: value),
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
          onSync: fetchSync,
          data: anggota.cast<Map<String, dynamic>>(),
          headers: [
            "Daurah ID",
            "Daurah Name",
            "Jumlah Anggota",
            "Periode Terakhir",
            "Tanggal Periode",
            "",
          ],
          fields: [
            "group_id",
            "group_name",
            "jumlah_anggota",
            "periode",
            "tanggal",
            "action",
          ],
          rowsPerPage: 10,
          currentPage: currentPage,
          lastPage: lastPage, // ⬅️ penting
          onPageChanged: (page) => fetchData(page: page),
          headerColor: Colors.green,
          rowColor: Colors.white,
          alternateRowColor: Colors.grey.shade100,
          onEdit: (row) => print("Edit row: $row"),
          onDelete: (row) {
            periodeCreate(daurah_id: row['group_id']);
          },
        ),
      ),
    );
  }
}
