import 'package:flutter/material.dart';
import 'package:hotmul_quran/widget/drawer.dart';
import 'package:hotmul_quran/widget/graph_daurah.dart';

class ReportMain extends StatefulWidget {
  const ReportMain({super.key});

  @override
  State<ReportMain> createState() => _ReportMainState();
}

class _ReportMainState extends State<ReportMain> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // jumlah tab
      child: Scaffold(
        endDrawer: AppDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          title: const Text('Laporan', style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            indicatorColor: Colors.white, // garis bawah putih
            labelColor: Colors.white, // teks tab aktif putih
            unselectedLabelColor:
                Colors.white70, // teks tab non-aktif putih transparan
            tabs: [
              Tab(
                icon: Icon(Icons.summarize, color: Colors.red[100]),
                text: "Sum",
              ),
              const Tab(
                icon: Icon(Icons.add_chart, color: Colors.lightBlue),
                text: "Graph",
              ),
              const Tab(
                icon: Icon(Icons.trending_up, color: Colors.amberAccent),
                text: "trend",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(
              child: Text(
                "Halaman Home",
                style: TextStyle(color: Colors.black), // biar konten kebaca
              ),
            ),
            Center(child: DaurahScreen()),
            Center(
              child: Text(
                "Halaman Settings",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
