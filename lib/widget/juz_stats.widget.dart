// lib/widgets/juz_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/juz_stats_model.dart';
import 'package:hotmul_quran/service/juz_stats_service.dart';

class JuzStatsWidget extends StatefulWidget {
  const JuzStatsWidget({super.key});

  @override
  State<JuzStatsWidget> createState() => _JuzStatsWidgetState();
}

class _JuzStatsWidgetState extends State<JuzStatsWidget> {
  final JuzStatsService _service = JuzStatsService();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _minJuzController = TextEditingController();
  final TextEditingController _maxJuzController = TextEditingController();

  int _currentTab = 0;
  late Future<JuzStatsResponse> _futureStats;

  @override
  void initState() {
    super.initState();
    _futureStats = _service.getJuzStatsWithStatus();
  }

  void _refreshData() {
    setState(() {
      _futureStats = _service.getJuzStatsWithStatus(
        groupId: _groupController.text.isNotEmpty
            ? _groupController.text
            : null,
        minJuz: _minJuzController.text.isNotEmpty
            ? int.parse(_minJuzController.text)
            : null,
        maxJuz: _maxJuzController.text.isNotEmpty
            ? int.parse(_maxJuzController.text)
            : null,
      );
    });
  }

  void _showAnggotaDetail(JuzStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stats.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${stats.anggotaId}'),
              Text('Group: ${stats.groupId}'),
              Text('Total Juz: ${stats.totalJuz}'),
              if (stats.daftarJuz != null && stats.daftarJuz!.isNotEmpty)
                Text('Daftar Juz: ${stats.daftarJuz}'),
              if (stats.tanggalMulai != null)
                Text('Mulai: ${stats.tanggalMulai}'),
              if (stats.tanggalTerakhir != null)
                Text('Terakhir: ${stats.tanggalTerakhir}'),
              if (stats.totalPeriode != null && stats.totalPeriode! > 0)
                Text('Total Periode: ${stats.totalPeriode}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Statistik Juz'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentTab = index;
                _refreshData();
              });
            },
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Detail'),
              Tab(text: 'Summary'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildDetailTab(),
            _buildSummaryTab(),
          ],
        ),
        floatingActionButton: _currentTab != 2
            ? FloatingActionButton(
                onPressed: _showFilterDialog,
                child: const Icon(Icons.filter_list),
              )
            : null,
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      children: [
        // Filter Info
        _buildFilterInfo(),

        // Data List
        Expanded(
          child: FutureBuilder<JuzStatsResponse>(
            future: _futureStats,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error.toString());
              } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return const Center(
                  child: Text('Tidak ada data yang ditemukan'),
                );
              } else {
                return _buildStatsList(snapshot.data!.data);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTab() {
    return FutureBuilder<JuzStatsResponse>(
      future: _service.getDetailedJuzStats(
        groupId: _groupController.text.isNotEmpty
            ? _groupController.text
            : null,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return const Center(child: Text('Tidak ada data detail'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.data.length,
            itemBuilder: (context, index) {
              final stats = snapshot.data!.data[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorByCount(stats.totalJuz),
                    child: Text(
                      stats.totalJuz.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(stats.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Group: ${stats.groupId}'),
                      if (stats.daftarJuz != null)
                        Text('Juz: ${stats.daftarJuz}'),
                      if (stats.tanggalMulai != null)
                        Text('Mulai: ${stats.tanggalMulai}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _showAnggotaDetail(stats),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFilterInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (_groupController.text.isNotEmpty)
            Chip(
              label: Text('Group: ${_groupController.text}'),
              onDeleted: () {
                _groupController.clear();
                _refreshData();
              },
            ),
          if (_minJuzController.text.isNotEmpty)
            Chip(
              label: Text('Min: ${_minJuzController.text} juz'),
              onDeleted: () {
                _minJuzController.clear();
                _refreshData();
              },
            ),
          if (_maxJuzController.text.isNotEmpty)
            Chip(
              label: Text('Max: ${_maxJuzController.text} juz'),
              onDeleted: () {
                _maxJuzController.clear();
                _refreshData();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatsList(List<JuzStats> statsList) {
    return ListView.builder(
      itemCount: statsList.length,
      itemBuilder: (context, index) {
        final stats = statsList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorByCount(stats.totalJuz),
              child: Text(
                stats.totalJuz.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(stats.name),
            subtitle: Text('Group: ${stats.groupId}'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _showAnggotaDetail(stats),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Data'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _groupController,
                decoration: const InputDecoration(
                  labelText: 'Group ID',
                  hintText: 'Masukkan group ID',
                ),
              ),
              TextField(
                controller: _minJuzController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Min Juz',
                  hintText: 'Jumlah minimal juz',
                ),
              ),
              TextField(
                controller: _maxJuzController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Juz',
                  hintText: 'Jumlah maksimal juz',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshData();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _service.getJuzStatsSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Tidak ada data summary'));
        } else {
          final data = snapshot.data!;
          final summaryData = data['data']['summary'] ?? {};
          final byGroup = data['data']['by_group'] as List<dynamic>? ?? [];

          // Safe parsing untuk summary
          final totalAnggota = _safeParseInt(summaryData['total_anggota']);
          final totalJuzDibaca = _safeParseInt(summaryData['total_juz_dibaca']);
          final persentaseAktif = _safeParseDouble(
            summaryData['persentase_aktif'],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Summary Keseluruhan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              'Total Anggota',
                              totalAnggota.toString(),
                            ),
                            _buildSummaryItem(
                              'Total Juz',
                              totalJuzDibaca.toString(),
                            ),
                            _buildSummaryItem(
                              'Aktif',
                              '${persentaseAktif.toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Per Group',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Group Stats dengan parsing yang aman
                ...byGroup.map((groupData) {
                  final groupId = groupData['group_id']?.toString() ?? 'N/A';
                  final totalJuz = _safeParseInt(groupData['total_juz_dibaca']);
                  final persentase = _safeParseDouble(
                    groupData['persentase_aktif'],
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('Group $groupId'),
                      subtitle: Text('$totalJuz juz dibaca'),
                      trailing: Chip(
                        label: Text('${persentase.toStringAsFixed(1)}% aktif'),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }
      },
    );
  }

  // Helper methods untuk safe parsing
  int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Color _getColorByCount(int count) {
    if (count >= 20) return Colors.green;
    if (count >= 10) return Colors.blue;
    if (count >= 5) return Colors.orange;
    if (count >= 1) return Colors.amber;
    return Colors.grey;
  }
}
