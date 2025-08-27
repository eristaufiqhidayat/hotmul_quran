// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/jadwal/jadwal_crud.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/pagination.dart';
import 'package:hotmul_quran/widget/refreshNew.dart';
import 'package:hotmul_quran/widget/searchbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hotmul_quran/service/token_services.dart';

class jadwalPage extends StatefulWidget {
  const jadwalPage({super.key});

  @override
  State<jadwalPage> createState() => _jadwalPageState();
}

class _jadwalPageState extends State<jadwalPage> {
  int currentPage = 1;
  int lastPage = 1;
  List<dynamic> anggota = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchData({int page = 1, String? search}) async {
    setState(() => isLoading = true);
    final token = await getToken(); // Ambil token dari SharedPreferences
    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/jadwal?page=$page&search=${search ?? ''}",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(title: "jadwal"),
      body: Column(
        children: [
          // Tombol Refresh + Add
          ActionButtons(
            onRefresh: () => fetchData(page: currentPage),
            onNew: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditjadwalPage(anggota: {}),
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
                          item['nama_acara'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tempat: ${item['nama_tempat']}"),
                            Text("waktu: ${item['waktu']}"),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.red),
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditjadwalPage(anggota: item),
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
          // ganti bagian Pagination
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PaginationWidget(
              currentPage: currentPage,
              lastPage: lastPage,
              onPageChanged: (page) => fetchData(page: page),
            ),
          ),
        ],
      ),
    );
  }
}
