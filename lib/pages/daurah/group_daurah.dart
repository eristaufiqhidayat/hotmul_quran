// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/daurah/daurah_crud.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/refreshNew.dart';
import 'package:hotmul_quran/widget/searchbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hotmul_quran/service/token_services.dart';

class DaurahPage extends StatefulWidget {
  const DaurahPage({super.key});

  @override
  State<DaurahPage> createState() => _DaurahPageState();
}

class _DaurahPageState extends State<DaurahPage> {
  int currentPage = 1;
  int lastPage = 1;
  List<dynamic> anggota = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchData({int page = 1, String? search}) async {
    setState(() => isLoading = true);
    final token = await getToken(); // Ambil token dari SharedPreferences
    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/daurah?page=$page&search=${search ?? ''}",
    );
    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    //print("response status code ${response.statusCode}");
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      // print(result);
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
      appBar: PrimaryAppBar(title: "Daurah"),
      body: Column(
        children: [
          // Tombol Refresh + Add
          ActionButtons(
            onRefresh: () => fetchData(page: currentPage),
            onNew: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDaurahPage(anggota: {}),
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
                        title: Text(item['group_name'] ?? ""),
                        subtitle: Text("Daurah id : ${item['group_id']}"),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.red),
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditDaurahPage(anggota: item),
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
