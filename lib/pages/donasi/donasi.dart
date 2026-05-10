// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/donasi/donasi_crud.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/widget/refreshNew.dart';
import 'package:hotmul_quran/widget/searchbar.dart';
import 'dart:convert';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:intl/intl.dart';

class DonasiPage extends StatefulWidget {
  const DonasiPage({super.key});

  @override
  State<DonasiPage> createState() => _DonasiPageState();
}

class _DonasiPageState extends State<DonasiPage> {
  String? groupId; // nilai dari local
  int currentPage = 1;
  int lastPage = 1;
  List<dynamic> anggota = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  var anggota_id;
  var group_user;
  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0, // tanpa desimal
  );
  Future<void> fetchData({int page = 1, String? search}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      // token kosong, langsung logout dan balik ke login
      await logout();
      return;
      // hentikan proses
    }

    final response = await ApiClient.get(
      "${GlobalConst.url}/api/v1/donasi?groupid=$groupId",
    );
    print("${GlobalConst.url}/api/v1/donasi?groupid=$groupId");
    print(response.body);
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
    initLoad();
  }

  Future<void> initLoad() async {
    _loadGroupId();
    anggota_id = await getAnggota_id();
    group_user = await getGroup_id();

    await fetchData();
  }

  Future<void> _loadGroupId() async {
    final idString = await getGroup_id();
    //print(idString); // fungsi dari token_services.dart
    setState(() {
      groupId = idString ?? "0"; // kalau null → "0"
      isLoading = false;
    });
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
    print("Group ID: $groupId");
    return Scaffold(
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Donasi"),
      body: Column(
        children: [
          // Tombol Refresh + Add
          groupId == "member"
              ? ActionButtons(
                  onRefresh: () => fetchData(page: currentPage),
                  onNew: null,
                  newButton: false, // atau bahkan ga perlu dikirim
                )
              : ActionButtons(
                  onRefresh: () => fetchData(page: currentPage),
                  onNew: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDonasiPage(anggota: {}),
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
                      return ListTile(
                        title: Text(
                          item['name'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatCurrency.format(
                                int.tryParse(item["rp"]?.toString() ?? '0') ??
                                    0,
                              ),
                            ),
                            Text("Tanggal: ${item['tanggal']}"),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: groupId == "admin"
                            ? PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.red,
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditDonasiPage(anggota: item),
                                      ),
                                    ).then((updated) {
                                      if (updated == true) {
                                        fetchData(
                                          page: currentPage,
                                        ); // refresh list kalau ada update
                                      }
                                    });
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text("Update"),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : null,
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
