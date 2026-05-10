import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/daurah/daurah_crud.dart';
import 'package:hotmul_quran/pages/daurah/list_anggota.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/widget/refreshNew.dart';
import 'package:hotmul_quran/widget/searchbar.dart';
import 'package:hotmul_quran/service/api_client.dart';

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

  /// FETCH DATA (REFACTORED)
  Future<void> fetchData({int page = 1, String? search}) async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiClient.get(
        "${GlobalConst.url}/api/v1/daurah?page=$page&search=${search ?? ''}",
      );
      print("Response daurah group: ${response.body}");
      if (response.statusCode == 200) {
        final result = ApiClient.decode(response);

        setState(() {
          anggota = result['data'];
          currentPage = result['current_page'];
          lastPage = result['last_page'];
        });
      }
    } catch (e) {
      if (e.toString().contains("Unauthorized")) {
        _redirectToLogin();
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  /// AUTO REDIRECT LOGIN
  void _redirectToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Daurah"),
      body: Column(
        children: [
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

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: anggota.length,
                    itemBuilder: (context, index) {
                      final item = anggota[index];

                      return ListTile(
                        title: Text(
                          item['group_name'] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Daurah id : ${item['id']}"),
                            Text("Jumlah Anggota : ${item['users_count']}"),
                          ],
                        ),
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
                                  fetchData(page: currentPage);
                                }
                              });
                            } else if (value == 'listangota') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ListAnggotaPage(group_id: item["id"]),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  fetchData(page: currentPage);
                                }
                              });
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text("Update"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'listangota',
                              child: Row(
                                children: [
                                  Icon(Icons.people, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("List Anggota"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'khotmul',
                              child: Row(
                                children: [
                                  Icon(Icons.book, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text("Khotmul/JUZ"),
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

          Padding(padding: const EdgeInsets.all(8.0), child: buildPagination()),
        ],
      ),
    );
  }
}
