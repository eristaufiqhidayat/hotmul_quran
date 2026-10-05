import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/model/daurah_model.dart';
import 'package:hotmul_quran/model/laporan_hapalan_model.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/service/daurah_service.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/hafalan_widgets.dart';

/// Dashboard admin: ringkasan anggota on-track / terlambat per grup pada
/// periode aktif (BRD 4.5, SRS FR-05, FR-10).
class AdminMonitoringPage extends StatefulWidget {
  const AdminMonitoringPage({super.key});

  @override
  State<AdminMonitoringPage> createState() => _AdminMonitoringPageState();
}

class _AdminMonitoringPageState extends State<AdminMonitoringPage> {
  final _api = ApiService();

  List<Daurah> _groups = [];
  Daurah? _group;
  List<LaporanHafalan> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = await _api.fetchDaurah();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _group = groups.isNotEmpty ? groups.first : null;
      });
      await _loadLaporan();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat grup: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadLaporan() async {
    final g = _group;
    if (g == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // periode 0 → API memakai periode khotmul yang aktif
      final rows = await _api.fetchLaporanByDaurah(g.id, 0);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat laporan: $e';
        _loading = false;
      });
    }
  }

  Future<void> _ubahStatus(LaporanHafalan row) async {
    final status = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Ubah status ${row.name} • Juz ${row.juz}'),
              subtitle: const Text(
                'Tandai selesai setelah setoran / badal disetujui admin',
              ),
            ),
            for (final s in const ['active', 'done', 'late'])
              ListTile(
                leading: Icon(
                  Icons.circle,
                  color: assignmentStatusStyle(s).color,
                ),
                title: Text(assignmentStatusStyle(s).label),
                trailing: row.status == s ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, s),
              ),
          ],
        ),
      ),
    );
    if (status == null || status == row.status || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final res = await ApiClient.put(
      "${GlobalConst.apiV1}/khatam/update-status",
      body: {"assignment_id": row.assignmentId, "status": status},
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ApiClient.errorMessage(
            res,
            fallback: res.statusCode == 200
                ? 'Status diperbarui'
                : 'Gagal update status',
          ),
        ),
      ),
    );
    if (res.statusCode == 200) _loadLaporan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: 'Monitoring Hafalan'),
      body: RefreshIndicator(
        onRefresh: _loadLaporan,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              initialValue: _group?.id,
              decoration: const InputDecoration(labelText: 'Grup'),
              items: _groups
                  .map(
                    (g) => DropdownMenuItem(value: g.id, child: Text(g.name)),
                  )
                  .toList(),
              onChanged: (id) {
                setState(() => _group = _groups.firstWhere((g) => g.id == id));
                _loadLaporan();
              },
            ),
            const SizedBox(height: 16),
            ..._content(),
          ],
        ),
      ),
    );
  }

  List<Widget> _content() {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        EmptyState(
          icon: Icons.cloud_off,
          message: _error!,
          onRetry: _loadGroups,
        ),
      ];
    }
    if (_rows.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.inbox_outlined,
          message: 'Belum ada jadwal juz untuk grup ini pada periode aktif.',
        ),
      ];
    }

    final done = _rows.where((r) => r.status == 'done').length;
    final late = _rows.where((r) => r.status == 'late').length;
    final active = _rows.length - done - late;
    final kosong = GlobalConst.maxAnggotaPerGroup - _rows.length;

    return [
      _SummaryCard(done: done, active: active, late: late),
      if (kosong > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '$kosong dari ${GlobalConst.maxAnggotaPerGroup} juz belum punya '
            'anggota di grup ini.',
            style: const TextStyle(color: ThemeConfig.late),
          ),
        ),
      const SizedBox(height: 16),
      Text(
        'Anggota (${_rows.length})',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      for (final r in _rows) ...[
        _MemberRow(row: r, onTap: () => _ubahStatus(r)),
        const SizedBox(height: 8),
      ],
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  final int done;
  final int active;
  final int late;

  const _SummaryCard({
    required this.done,
    required this.active,
    required this.late,
  });

  @override
  Widget build(BuildContext context) {
    final total = done + active + late;
    PieChartSectionData section(int v, Color c) => PieChartSectionData(
      value: v.toDouble(),
      color: c,
      radius: 22,
      showTitle: false,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 32,
                      sectionsSpace: 2,
                      sections: [
                        if (done > 0) section(done, ThemeConfig.onTrack),
                        if (active > 0) section(active, ThemeConfig.warning),
                        if (late > 0) section(late, ThemeConfig.late),
                      ],
                    ),
                  ),
                  Text(
                    total == 0 ? '-' : '${(done * 100 / total).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legend('Selesai', done, ThemeConfig.onTrack),
                  _legend('Berjalan', active, ThemeConfig.warning),
                  _legend('Terlambat', late, ThemeConfig.late),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final LaporanHafalan row;
  final VoidCallback onTap;

  const _MemberRow({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final st = assignmentStatusStyle(row.status);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: st.color.withValues(alpha: 0.15),
          child: Text(
            '${row.juz}',
            style: TextStyle(color: st.color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(row.name),
        subtitle: Text(
          row.status == 'late'
              ? 'Terlambat • juz bisa diambil alih anggota lain (badal)'
              : 'Juz ${row.juz} • tenggat ${row.lastInput}',
        ),
        trailing: StatusChip(label: st.label, color: st.color),
      ),
    );
  }
}
