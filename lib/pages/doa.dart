import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ------------------ MODEL ------------------
class Doa {
  final int id;
  final String judul;
  final String arab;
  final String latin;
  final String arti;

  Doa({
    required this.id,
    required this.judul,
    required this.arab,
    required this.latin,
    required this.arti,
  });

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      arab: json['arab'] ?? '',
      latin: json['latin'] ?? '',
      arti: json['terjemah'] ?? '',
    );
  }
}

// ------------------ SERVICE ------------------
class DoaService {
  static const String baseUrl = 'https://open-api.my.id/api';

  Future<List<Doa>> fetchDoaList() async {
    final url = Uri.parse('$baseUrl/doa');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded.map((e) => Doa.fromJson(e)).toList();
      } else if (decoded['data'] != null && decoded['data'] is List) {
        return (decoded['data'] as List).map((e) => Doa.fromJson(e)).toList();
      } else {
        final list = decoded['result'] ?? decoded['list'] ?? [];
        return (list as List).map((e) => Doa.fromJson(e)).toList();
      }
    } else {
      throw Exception('Failed to load doa');
    }
  }

  Future<Doa> fetchDoaDetail(int id) async {
    final url = Uri.parse('$baseUrl/doa/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['data'] != null) return Doa.fromJson(decoded['data']);
      return Doa.fromJson(decoded);
    } else {
      throw Exception('Failed to load doa detail');
    }
  }
}

// ------------------ MAIN APP ------------------
class DoaApp extends StatelessWidget {
  const DoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doa App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade50,
      ),
      home: const DoaListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ------------------ DOA LIST PAGE ------------------
class DoaListPage extends StatefulWidget {
  const DoaListPage({super.key});

  @override
  State<DoaListPage> createState() => _DoaListPageState();
}

class _DoaListPageState extends State<DoaListPage> {
  final DoaService _service = DoaService();
  late Future<List<Doa>> _futureDoa;

  @override
  void initState() {
    super.initState();
    _futureDoa = _service.fetchDoaList();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureDoa = _service.fetchDoaList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kumpulan Doa'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<List<Doa>>(
        future: _futureDoa,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) return const Center(child: Text('Data doa kosong'));

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final doa = list[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green.shade700, width: 1.5),
                  ),
                  color: Colors.green.shade100,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    title: Text(
                      doa.judul,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        doa.arab,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DoaDetailPage(
                            doaId: doa.id,
                            doaService: _service,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ------------------ DOA DETAIL PAGE ------------------
class DoaDetailPage extends StatefulWidget {
  final int doaId;
  final DoaService doaService;
  const DoaDetailPage({
    super.key,
    required this.doaId,
    required this.doaService,
  });

  @override
  State<DoaDetailPage> createState() => _DoaDetailPageState();
}

class _DoaDetailPageState extends State<DoaDetailPage> {
  late Future<Doa> _futureDoa;

  @override
  void initState() {
    super.initState();
    _futureDoa = widget.doaService.fetchDoaDetail(widget.doaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Doa'),
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<Doa>(
        future: _futureDoa,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final doa = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Judul Doa
                Text(
                  doa.judul,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 16),

                // Arab
                if (doa.arab.isNotEmpty) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.green.shade700,
                        width: 1.5,
                      ),
                    ),
                    color: Colors.green.shade50,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        doa.arab,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                  ),
                ],

                // Latin
                if (doa.latin.isNotEmpty) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.green.shade700,
                        width: 1.5,
                      ),
                    ),
                    color: Colors.green.shade50,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        doa.latin,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],

                // Terjemahan
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green.shade700, width: 1.5),
                  ),
                  color: Colors.green.shade50,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(doa.arti, style: const TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  'Sumber: open-api.my.id • Verifikasi disarankan untuk penggunaan resmi.',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
