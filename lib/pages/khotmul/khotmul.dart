// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/khotmul/khotmul_crud.dart';
import 'package:hotmul_quran/pages/khotmul/rekaman_audio.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/refreshNew.dart';
import 'package:hotmul_quran/widget/searchbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hotmul_quran/service/token_services.dart';

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
  var anggota_id;
  var group_id;

  Future<void> fetchData({int page = 1, String? search}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/khotmul?group_id=$group_id&page=$page&search=${search ?? ''}",
    );

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    print(
      "${GlobalConst.url}/api/v1/khotmul?group_id=$group_id&page=$page&search=${search ?? ''}",
    );
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
  }

  Future<void> _loadAnggotaId() async {
    anggota_id = await getAnggota_id();
    if (mounted) setState(() {});
  }

  Future<void> _loadGroupId() async {
    group_id = await getGroup_id();
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: i == currentPage ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                "$i",
                style: TextStyle(
                  color: i == currentPage ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      } else if (i == currentPage - 3 || i == currentPage + 3) {
        pages.add(const Text("..."));
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: pages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(title: "Khotmul Quran"),
      body: Column(
        children: [
          // Tombol Refresh + Add
          ActionButtons(
            onRefresh: () => fetchData(page: currentPage),
            onNew: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditKhotmulPage(anggota: {}),
                ),
              ).then((updated) {
                if (updated == true) fetchData(page: currentPage);
              });
            },
          ),
          SearchFieldWidget(
            controller: searchController,
            onSubmitted: (value) => fetchData(page: 1, search: value),
          ),
          const SizedBox(height: 10),

          // List Data
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: anggota.length,
                    itemBuilder: (context, index) {
                      final item = anggota[index];
                      MaterialColor warna;
                      IconData button;
                      item['status'] == "" || item['status'] == null
                          ? {warna = Colors.red, button = Icons.close}
                          : {warna = Colors.green, button = Icons.check};
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: warna,
                          child: Text(
                            item['juz'] != null ? item['juz'].toString() : '-',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          "Juz ${item['juz'] ?? ''}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: anggota_id == item['anggota_id'].toString()
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nama : ${item['name'] ?? '-'}\nGroup : ${item['group_id'] ?? '-'}\nPeriode : ${item['periode'] ?? '-'}\n",
                              style: TextStyle(
                                color: warna,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Status ",
                                  style: TextStyle(
                                    color: warna,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(button, color: warna),
                              ],
                            ),
                          ],
                        ),

                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.red),
                          onSelected: (value) {
                            if (value == 'khatam') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecorderPage(khotmulId: item['id']),
                                ),
                              );
                            } else if (value == 'donasi') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Add Donasi ${item['name']}"),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'khatam',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.record_voice_over,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text("Add Khatam"),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'donasi',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(width: 8),
                                  Text("Add Donasi"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.grey, height: 1),
                  ),
          ),

          // Pagination
          Padding(padding: const EdgeInsets.all(8.0), child: buildPagination()),
        ],
      ),
    );
  }
}
