import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model
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

// Service
class DoaService {
  // Endpoint publik (contoh: open-api.my.id)
  static const String baseUrl = 'https://open-api.my.id/api';

  Future<List<Doa>> fetchDoaList() async {
    final url = Uri.parse('$baseUrl/doa');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Perhatikan: beberapa API membungkus data; menyesuaikan struktur response
      // open-api.my.id mengembalikan array JSON langsung atau objek; handle aman:
      if (decoded is List) {
        return decoded
            .map((e) => Doa.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (decoded is Map &&
          decoded['data'] != null &&
          decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((e) => Doa.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // fallback: coba ambil 'result' atau 'list'
        final list = decoded['result'] ?? decoded['list'] ?? [];
        if (list is List) {
          return list
              .map((e) => Doa.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      throw Exception('Unexpected response structure');
    } else {
      throw Exception('Failed to load doa (status ${response.statusCode})');
    }
  }

  Future<Doa> fetchDoaDetail(int id) async {
    final url = Uri.parse('$baseUrl/doa/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['data'] != null) {
        return Doa.fromJson(decoded['data'] as Map<String, dynamic>);
      } else if (decoded is Map && decoded['id'] != null) {
        return Doa.fromJson(decoded as Map<String, dynamic>);
      } else {
        // Jika API mengembalikan langsung objek
        return Doa.fromJson(decoded as Map<String, dynamic>);
      }
    } else {
      throw Exception(
        'Failed to load doa detail (status ${response.statusCode})',
      );
    }
  }
}

class DoaApp extends StatelessWidget {
  const DoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doa App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const DoaListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Doa>>(
        future: _futureDoa,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Data doa kosong'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doa = list[index];
                    return ListTile(
                      title: Text(doa.judul),
                      subtitle: Text(doa.arab),
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
                    );
                  },
                ),
              ),
              // Attribution footer
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[100],
                child: const Text(
                  'Sumber data: open-api.my.id (SantriKoding). Verifikasi teks untuk keperluan resmi.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

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
      appBar: AppBar(title: const Text('Detail Doa')),
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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    doa.judul,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  if (doa.arab.isNotEmpty) ...[
                    Text(
                      'Arab',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      doa.arab,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (doa.latin.isNotEmpty) ...[
                    Text(
                      'Latin',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(doa.latin),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    'Terjemahan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(doa.arti),
                  const SizedBox(height: 20),
                  Text(
                    'Sumber: open-api.my.id • Verifikasi disarankan untuk penggunaan resmi.',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
