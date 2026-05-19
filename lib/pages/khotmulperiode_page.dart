import 'package:flutter/material.dart';
import '../repositories/assignment_repo.dart';

class KhotmulPeriode_Page extends StatefulWidget {
  const KhotmulPeriode_Page({super.key});

  @override
  State<KhotmulPeriode_Page> createState() => _KhotmulPeriode_PageState();
}

class _KhotmulPeriode_PageState extends State<KhotmulPeriode_Page> {
  Map<String, dynamic>? response;

  List data = [];
  List dataPeriodeActive = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
    print('Masuk ke class: $runtimeType');
  }

  Future<void> load() async {
    final res = await AssignmentRepo().getToday();

    setState(() {
      response = res;
      data = res?['data'] ?? [];
      loading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;

      case 'done':
        return Colors.blue;

      case 'late':
        return Colors.orange;
      case 'next':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.play_circle;

      case 'done':
        return Icons.check_circle;

      case 'late':
        return Icons.warning;

      case 'next':
        return Icons.access_time;

      default:
        return Icons.info;
    }
  }

  /// ===============================
  /// FORM NEW / EDIT
  /// ===============================

  Future<void> showForm({dynamic item}) async {
    final res = await AssignmentRepo().getPeriodeLast();
    setState(() {
      /// FIX
      if (res?['data'] != null) {
        dataPeriodeActive = [res!['data']];
      } else {
        dataPeriodeActive = [];
      }
    });
    final TextEditingController periodeC = TextEditingController(
      text: item?['periode']?.toString() ?? '',
    );

    final TextEditingController tanggalMulaiC = TextEditingController(
      text: item?['tanggal_mulai']?.toString() ?? '',
    );

    final TextEditingController tanggalSelesaiC = TextEditingController(
      text: item?['tanggal_selesai']?.toString() ?? '',
    );

    String status = item?['status'] ?? 'active';
    if (periodeC.text.isEmpty) {
      periodeC.text = (dataPeriodeActive[0]['periode'] + 1).toString();

      /// tanggal selesai lama
      DateTime lastDate = DateTime.parse(
        dataPeriodeActive[0]['tanggal_selesai'],
      );

      /// mulai baru = +1 hari
      tanggalMulaiC.text = lastDate
          .add(const Duration(days: 1))
          .toString()
          .split(" ")[0];

      /// selesai baru = +15 hari
      tanggalSelesaiC.text = lastDate
          .add(const Duration(days: 15))
          .toString()
          .split(" ")[0];
    }
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(item == null ? "Tambah Periode" : "Edit Periode"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// PERIODE
                    TextField(
                      controller: periodeC,
                      decoration: const InputDecoration(
                        labelText: "Periode",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// TANGGAL MULAI
                    TextField(
                      controller: tanggalMulaiC,
                      decoration: const InputDecoration(
                        labelText: "Tanggal Mulai",
                        hintText: "2026-05-01",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// TANGGAL SELESAI
                    TextField(
                      controller: tanggalSelesaiC,
                      decoration: const InputDecoration(
                        labelText: "Tanggal Selesai",
                        hintText: "2026-05-31",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// STATUS
                    DropdownButtonFormField(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "active",
                          child: Text("ACTIVE"),
                        ),
                        DropdownMenuItem(value: "done", child: Text("DONE")),
                        DropdownMenuItem(value: "late", child: Text("LATE")),
                        DropdownMenuItem(value: "next", child: Text("NEXT")),
                      ],
                      onChanged: (v) {
                        setModalState(() {
                          status = v.toString();
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Batal"),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () async {
                    final body = {
                      "periode": periodeC.text,
                      "tanggal_mulai": tanggalMulaiC.text,
                      "tanggal_selesai": tanggalSelesaiC.text,
                      "status": status,
                    };

                    print(body);

                    /// =====================
                    /// INSERT / UPDATE API
                    /// =====================

                    Map<String, dynamic>? result;

                    if (item == null) {
                      /// INSERT
                      result = await AssignmentRepo().insert(body);
                    } else {
                      /// UPDATE
                      result = await AssignmentRepo().update(
                        int.parse(item['id'].toString()),
                        body,
                      );
                    }

                    Navigator.pop(context);

                    if (result != null && result['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            item == null
                                ? "Data berhasil ditambah"
                                : "Data berhasil diupdate",
                          ),
                        ),
                      );

                      load();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result?['message'] ?? "Terjadi kesalahan",
                          ),
                        ),
                      );
                    }
                  },

                  icon: const Icon(Icons.save),
                  label: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ===============================
  /// DELETE
  /// ===============================

  Future<void> deleteData(dynamic item) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),

        content: Text("Yakin ingin menghapus periode ${item['periode']} ?"),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),

            onPressed: () async {
              final result = await AssignmentRepo().delete(
                int.parse(item['id'].toString()),
              );

              Navigator.pop(context);

              if (result != null && result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil dihapus")),
                );

                load();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result?['message'] ?? "Gagal menghapus data"),
                  ),
                );
              }
            },

            icon: const Icon(Icons.delete),
            label: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Khotmul Periode"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            onPressed: () {
              showForm();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          showForm();
        },
        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
          ? const Center(child: Text("Tidak ada data"))
          : RefreshIndicator(
              onRefresh: () async {
                await load();
              },

              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: data.length,

                itemBuilder: (context, index) {
                  final item = data[index];

                  final status = item['status'] ?? 'unknown';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          /// HEADER
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: getStatusColor(status),

                                child: Icon(
                                  getStatusIcon(status),
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "Periode ${item['periode']}",

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "Tanggal: ${item['tanggal']}",

                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: getStatusColor(status),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Text(
                                  status.toUpperCase(),

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.green,
                              ),

                              const SizedBox(width: 8),

                              Text("Mulai: ${item['tanggal_mulai']}"),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(
                                Icons.event,
                                size: 18,
                                color: Colors.red,
                              ),

                              const SizedBox(width: 8),

                              Text("Selesai: ${item['tanggal_selesai']}"),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// BUTTON
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,

                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),

                                onPressed: () {
                                  showForm(item: item);
                                },

                                icon: const Icon(Icons.edit),

                                label: const Text("Edit"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),

                                onPressed: () {
                                  deleteData(item);
                                },

                                icon: const Icon(Icons.delete),

                                label: const Text("Delete"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
