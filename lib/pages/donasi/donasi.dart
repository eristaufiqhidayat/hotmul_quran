// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/donasi/donasi_crud.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hotmul_quran/service/token_services.dart';

class DonasiPage extends StatefulWidget {
  const DonasiPage({super.key});

  @override
  State<DonasiPage> createState() => _DonasiPageState();
}

class _DonasiPageState extends State<DonasiPage> {
  int currentPage = 1;
  int lastPage = 1;
  List<dynamic> anggota = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchData({int page = 1, String? search}) async {
    setState(() => isLoading = true);
    final token = await getToken(); // Ambil token dari SharedPreferences
    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/donasi?page=$page&search=${search ?? ''}",
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
      appBar: PrimaryAppBar(title: "Donasi"),
      body: Column(
        children: [
          // Tombol Refresh + Add
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    fetchData(page: currentPage);
                  },
                  child: const Icon(Icons.refresh, color: Colors.black),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.red; // saat ditekan
                      } else if (states.contains(MaterialState.hovered)) {
                        return Colors
                            .yellow
                            .shade100; // saat hover (desktop/web)
                      }
                      return Colors.yellow.shade100; // default
                    }),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // biar kotak
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDonasiPage(anggota: {}),
                      ),
                    ).then((updated) {
                      if (updated == true) {
                        fetchData(
                          page: currentPage,
                        ); // refresh list kalau ada update
                      }
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "New",
                    style: TextStyle(
                      color: Colors.white, // tulisan putih
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.red; // saat ditekan
                      } else if (states.contains(MaterialState.hovered)) {
                        return Colors.blue.shade900; // saat hover (desktop/web)
                      }
                      return Colors.blue.shade900; // default
                    }),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // biar kotak
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(
                    0.1,
                  ), // background agak opal
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // sudut melengkung
                    borderSide: const BorderSide(
                      color: Colors.grey, // warna border
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue, // warna border saat fokus
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (value) => fetchData(page: 1, search: value),
              ),
            ),
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
                        title: Text(item['group_name'].toString()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Jumlah Donasi: ${item['rp']}"),
                            Text("Tanggal: ${item['tanggal']}"),
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
