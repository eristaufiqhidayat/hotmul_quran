// lib/widgets/khotmul_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/khotmul_stats.dart';
import 'package:hotmul_quran/service/khotmul_service.dart';

class KhotmulStatsWidget extends StatefulWidget {
  final String? groupId;

  const KhotmulStatsWidget({super.key, this.groupId});

  @override
  State<KhotmulStatsWidget> createState() => _KhotmulStatsWidgetState();
}

class _KhotmulStatsWidgetState extends State<KhotmulStatsWidget> {
  final KhotmulService _service = KhotmulService();
  late Future<KhotmulResponse> _futureStats;
  final TextEditingController _groupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureStats = widget.groupId != null
        ? _service.getKhotmulStatsByGroup(widget.groupId!)
        : _service.getKhotmulStats();
  }

  void _refreshData() {
    setState(() {
      _futureStats = widget.groupId != null
          ? _service.getKhotmulStatsByGroup(widget.groupId!)
          : _service.getKhotmulStats();
    });
  }

  void _filterByGroup() {
    if (_groupController.text.isNotEmpty) {
      setState(() {
        _futureStats = _service.getKhotmulStatsByGroup(_groupController.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Statistik Khotmul'),
      //   actions: [
      //     IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
      //   ],
      // ),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _groupController,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Group ID',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.filter_list),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _filterByGroup,
                  child: const Text('Filter'),
                ),
              ],
            ),
          ),

          // Data Section
          Expanded(
            child: FutureBuilder<KhotmulResponse>(
              future: _futureStats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data yang ditemukan'),
                  );
                } else {
                  return _buildStatsList(snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsList(KhotmulResponse response) {
    return ListView.builder(
      itemCount: response.data.length,
      itemBuilder: (context, index) {
        final stats = response.data[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getColorByCount(stats.jumlahKhotmul),
              child: Text(
                stats.jumlahKhotmul.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              stats.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('User ID: ${stats.userId}'),
                Text('Group: ${stats.groupId}'),
                if (stats.daftarJuz.isNotEmpty) Text('Juz: ${stats.daftarJuz}'),
                if (stats.daftarTanggal.isNotEmpty)
                  Text('Tanggal: ${stats.daftarTanggal}'),
              ],
            ),
            trailing: Icon(
              _getIconByCount(stats.jumlahKhotmul),
              color: _getColorByCount(stats.jumlahKhotmul),
            ),
          ),
        );
      },
    );
  }

  Color _getColorByCount(int count) {
    if (count >= 10) return Colors.green;
    if (count >= 5) return Colors.blue;
    if (count >= 1) return Colors.orange;
    return Colors.grey;
  }

  IconData _getIconByCount(int count) {
    if (count >= 10) return Icons.emoji_events;
    if (count >= 5) return Icons.star;
    if (count >= 1) return Icons.check_circle;
    return Icons.circle;
  }
}
