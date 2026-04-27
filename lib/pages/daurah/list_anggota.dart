import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/pages/anggota/anggota_crud.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/widget/refreshNew.dart';
import 'package:hotmul_quran/widget/searchbar.dart';
import 'package:hotmul_quran/service/api_client.dart';

class ListAnggotaPage extends StatefulWidget {
  final int group_id;
  const ListAnggotaPage({super.key, required this.group_id});

  @override
  State<ListAnggotaPage> createState() => _ListAnggotaPageState();
}

class _ListAnggotaPageState extends State<ListAnggotaPage> {
  int currentPage = 1;
  int lastPage = 1;
  List<dynamic> anggota = [];
  bool isLoading = false;

  TextEditingController searchController = TextEditingController();

  /// FETCH DATA (REFRACTOR)
  Future<void> fetchData({int page = 1, String? search}) async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiClient.get(
        "${GlobalConst.url}/api/v1/anggota?group_id=${widget.group_id}&page=$page&search=${search ?? ''}",
      );

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

  /// AUTO LOGOUT / REDIRECT
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
      appBar: PrimaryAppBar(title: "Anggota"),
      body: Column(
        children: [
          ActionButtons(
            onRefresh: () => fetchData(page: currentPage),
            onNew: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditAnggotaPage(anggota: {}, daurah_id: widget.group_id),
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

                      final int perPage = anggota.isNotEmpty
                          ? anggota.length
                          : 10;

                      final noUrut = (index + 1) + (currentPage - 1) * perPage;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            "$noUrut",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item['name'] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // subtitle: Text(
                        //   "User id : ${item['user_id']}, Daurah : ${item['daurah_id']}",
                        // ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.red),
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditAnggotaPage(anggota: item),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  fetchData(page: currentPage);
                                }
                              });
                            } else if (value == 'delete') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Delete ${item['name']}"),
                                ),
                              );
                            } else if (value == 'khatam') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Add Khatam ${item['name']}"),
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
                            PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'khatam',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text("Add Khatam"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
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

          Padding(padding: const EdgeInsets.all(8.0), child: buildPagination()),
        ],
      ),
    );
  }
}
