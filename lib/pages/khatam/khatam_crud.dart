import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/widget/appbar.dart';
import 'package:hotmul_quran/widget/custom_textfile.dart';
import 'package:hotmul_quran/widget/datetimepicker.dart';
import 'package:hotmul_quran/widget/drawer.dart';

class EditKhatamPage extends StatefulWidget {
  final Map<String, dynamic> anggota;

  const EditKhatamPage({super.key, required this.anggota});

  @override
  State<EditKhatamPage> createState() => _EditKhatamPageState();
}

class _EditKhatamPageState extends State<EditKhatamPage> {
  late TextEditingController id;
  late TextEditingController jumlah_khatam;
  late TextEditingController jumlah_membadalkan;
  late TextEditingController jumlah_tidak_baca;
  late TextEditingController keterangan;
  late TextEditingController tanggal;

  List<dynamic> groups = [];
  bool isLoadingGroups = true;
  String? selectedUserId;

  @override
  void initState() {
    super.initState();

    id = TextEditingController(text: widget.anggota['id']?.toString() ?? '');
    jumlah_khatam = TextEditingController(
      text: widget.anggota['jumlah_khatam']?.toString() ?? '',
    );
    jumlah_membadalkan = TextEditingController(
      text: widget.anggota['jumlah_membadalkan']?.toString() ?? '',
    );
    jumlah_tidak_baca = TextEditingController(
      text: widget.anggota['jumlah_tidak_baca']?.toString() ?? '',
    );
    keterangan = TextEditingController(
      text: widget.anggota['keterangan'] ?? '',
    );
    tanggal = TextEditingController(text: widget.anggota['tanggal'] ?? '');

    selectedUserId = widget.anggota['user_id']?.toString();

    fetchGroups();
  }

  /// =======================
  /// FETCH GROUPS (REFRACTOR)
  /// =======================
  Future<void> fetchGroups() async {
    setState(() => isLoadingGroups = true);

    try {
      final response = await ApiClient.get(
        "${GlobalConst.url}/api/v1/anggota2",
      );

      if (response.statusCode == 200) {
        final body = ApiClient.decode(response);

        List<dynamic> list = body is Map && body.containsKey('data')
            ? body['data']
            : body;

        setState(() {
          groups = list;
        });
      }
    } catch (e) {
      _handleUnauthorized(e);
    }

    setState(() => isLoadingGroups = false);
  }

  /// =======================
  /// SAVE EDIT (REFRACTOR)
  /// =======================
  Future<void> saveEdit() async {
    if (selectedUserId == null) return;

    final response = await ApiClient.put(
      "${GlobalConst.url}/api/v1/khatam/${id.text}",
      body: {
        "user_id": selectedUserId,
        "jumlah_khatam": jumlah_khatam.text,
        "jumlah_membadalkan": jumlah_membadalkan.text,
        "jumlah_tidak_baca": jumlah_tidak_baca.text,
        "keterangan": keterangan.text,
        "tanggal": tanggal.text,
      },
    );

    _handleSaveResponse(response, "Update");
  }

  /// =======================
  /// SAVE NEW (REFRACTOR)
  /// =======================
  Future<void> saveNew() async {
    if (selectedUserId == null) return;

    final response = await ApiClient.post(
      "${GlobalConst.url}/api/v1/khatam/",
      body: {
        "user_id": selectedUserId,
        "jumlah_khatam": jumlah_khatam.text,
        "jumlah_membadalkan": jumlah_membadalkan.text,
        "jumlah_tidak_baca": jumlah_tidak_baca.text,
        "keterangan": keterangan.text,
        "tanggal": tanggal.text,
      },
    );

    _handleSaveResponse(response, "Insert");
  }

  /// =======================
  /// DELETE (REFRACTOR)
  /// =======================
  Future<void> saveDelete() async {
    final response = await ApiClient.delete(
      "${GlobalConst.url}/api/v1/khatam/${id.text}",
    );

    _handleSaveResponse(response, "Delete");
  }

  /// =======================
  /// HANDLE RESPONSE
  /// =======================
  void _handleSaveResponse(response, String action) {
    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Berhasil $action data")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal $action data")));
    }
  }

  /// =======================
  /// HANDLE ERROR AUTH
  /// =======================
  void _handleUnauthorized(dynamic e) {
    if (e.toString().contains("Unauthorized")) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  String _groupLabel(dynamic item) {
    return (item['name'] ?? item['group_name'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: AppDrawer(),
      appBar: PrimaryAppBar(title: "Edit Khatam"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: id, label: "ID", icon: Icons.badge),

            const SizedBox(height: 16),

            isLoadingGroups
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: selectedUserId,
                    decoration: const InputDecoration(
                      labelText: "User/Group",
                      border: OutlineInputBorder(),
                    ),
                    items: groups.map((e) {
                      final val = e['user_id']?.toString();
                      return DropdownMenuItem(
                        value: val,
                        child: Text(_groupLabel(e)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedUserId = val),
                  ),

            const SizedBox(height: 16),

            CustomTextField(
              controller: jumlah_khatam,
              label: "Khatam",
              icon: Icons.book,
            ),
            CustomTextField(
              controller: jumlah_membadalkan,
              label: "Membadalkan",
              icon: Icons.person,
            ),
            CustomTextField(
              controller: jumlah_tidak_baca,
              label: "Tidak Baca",
              icon: Icons.person,
            ),
            CustomTextField(
              controller: keterangan,
              label: "Keterangan",
              icon: Icons.notes,
            ),

            DatePickerField(label: "Tanggal", controller: tanggal),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.anggota["id"] != null
                        ? saveEdit
                        : saveNew,
                    child: Text(
                      widget.anggota["id"] != null ? "Update" : "Simpan",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (widget.anggota["id"] != null)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: saveDelete,
                      child: const Text("Hapus"),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
