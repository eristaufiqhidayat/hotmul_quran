import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';

class PeriodeDaurahDropdown extends StatefulWidget {
  final int groupId;
  final Function(Map<String, dynamic> value)? onChanged;

  const PeriodeDaurahDropdown({
    super.key,
    required this.groupId,
    this.onChanged,
  });

  @override
  State<PeriodeDaurahDropdown> createState() => _PeriodeDaurahDropdownState();
}

class _PeriodeDaurahDropdownState extends State<PeriodeDaurahDropdown> {
  List<dynamic> items = [];

  static const String baseUrl = GlobalConst.url + '/api/v1';

  Map<String, dynamic>? selectedItem;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    print('Masuk ke class: $runtimeType');
    fetchData();
  }

  @override
  void didUpdateWidget(covariant PeriodeDaurahDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// jika group berubah
    if (oldWidget.groupId != widget.groupId) {
      print(
        "GROUP BERUBAH "
        "${oldWidget.groupId} -> ${widget.groupId}",
      );

      /// reset selected item
      selectedItem = null;

      /// reset data lama
      items = [];

      /// reload data baru
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await ApiClient.get("$baseUrl/periodeDaurah");

      final body = jsonDecode(response.body);

      List data = body['data'];

      items = data.where((e) {
        return e['id'].toString() == widget.groupId.toString();
      }).toList();
      items.sort((a, b) {
        return b['periode_group'].compareTo(a['periode_group']);
      });

      /// default pilih item pertama
      if (items.isNotEmpty) {
        selectedItem = items.first;

        if (widget.onChanged != null) {
          widget.onChanged!(selectedItem!);
        }
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<Map<String, dynamic>>(
      value: selectedItem,

      isExpanded: true,

      decoration: const InputDecoration(
        labelText: 'Pilih Periode',
        border: OutlineInputBorder(),
      ),

      items: items.map((item) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: item,

          child: Text(
            "Periode "
            "${item['periode_group']}",
          ),
        );
      }).toList(),

      onChanged: (value) {
        print("SELECTED:");
        print(value);

        setState(() {
          selectedItem = value;
        });

        if (widget.onChanged != null && value != null) {
          widget.onChanged!(value);
        }
      },
    );
  }
}
