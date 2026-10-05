import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/core/hafalan_rules.dart';
import 'package:hotmul_quran/model/assignment_model.dart';
import 'package:hotmul_quran/model/setoran_model.dart';
import 'package:hotmul_quran/pages/notification_page.dart';
import 'package:hotmul_quran/pages/setoranListPage.dart';
import 'package:hotmul_quran/repositories/hafalan_repo.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/hafalan_widgets.dart';

/// Beranda anggota: juz aktif periode ini, progres 2 pekan, tenggat,
/// dan tombol lapor hafalan harian (BRD 4.2–4.4).
class MemberHomePage extends StatefulWidget {
  const MemberHomePage({super.key});

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  final _repo = HafalanRepo();

  bool _loading = true;
  String? _error;
  String _name = '';
  Assignment? _assignment;
  SetoranGroup? _group;
  SetoranAnggota? _me;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final name = await getUser() ?? '';
      final userId = int.tryParse(await getUser_id() ?? '');
      final assignment = await _repo.getActiveAssignment();
      SetoranGroup? group;
      try {
        group = await _repo.getSetoranHariIni();
      } catch (_) {
        // rekap grup opsional; beranda tetap tampil dari assignment
      }
      if (!mounted) return;
      setState(() {
        _name = name;
        _assignment = assignment;
        _group = group;
        _me = group?.byUser(userId);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openSetor() async {
    final a = _assignment;
    if (a == null) return;
    final result = await Navigator.pushNamed(
      context,
      '/setoran-hafalan',
      arguments: {'juz': a.juzNumber, 'target_ayat': _me?.targetAyat ?? 0},
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: 'Beranda Hafalan',
        leading: [
          IconButton(
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(
        children: [
          EmptyState(icon: Icons.cloud_off, message: _error!, onRetry: _load),
        ],
      );
    }

    // API mengembalikan 404 di /assignment-active setelah assignment `done`,
    // jadi juz periode ini diambil dari rekap grup sebagai cadangan.
    final a =
        _assignment ??
        (_me?.juz != null ? Assignment(id: 0, juzNumber: _me!.juz!) : null);
    final bisaSetor = _assignment != null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Assalamu'alaikum, ${_name.isEmpty ? 'Sahabat Qur\'an' : _name}",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (_group != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_group!.groupName} • Periode ${_group!.periode ?? '-'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 16),
        if (a == null)
          const Card(
            child: EmptyState(
              icon: Icons.hourglass_empty,
              message:
                  'Belum ada juz aktif.\nAdmin akan memasukkan Anda ke grup '
                  'dan jadwal bergulir akan membagikan juz setiap 2 pekan.',
            ),
          )
        else ...[
          _AssignmentCard(assignment: a, me: _me),
          const SizedBox(height: 16),
          _TodayCard(me: _me, onSetor: bisaSetor ? _openSetor : null),
        ],
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Rekap setoran grup'),
            subtitle: const Text('Lihat progres anggota lain di grup Anda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetoranListPage()),
              );
              _load();
            },
          ),
        ),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final SetoranAnggota? me;

  const _AssignmentCard({required this.assignment, this.me});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final fmt = DateFormat('d MMM yyyy');
    final day = assignment.dayOfPeriod(today);
    final remaining = assignment.daysRemaining(today);
    final total = me?.totalAyat ?? 0;
    final target = me?.targetAyat ?? 0;
    final progress = HafalanRules.progress(total, target);
    final level = HafalanRules.level(
      progress: progress,
      dayOfPeriod: day,
      status: me?.statusAssignment,
      daysRemaining: remaining,
    );
    final color = colorForLevel(level);
    final reminder = remaining == null
        ? null
        : HafalanRules.deadlineReminder(remaining, juz: assignment.juzNumber);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${assignment.juzNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juz ${assignment.juzNumber}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (assignment.startDate != null &&
                          assignment.endDate != null)
                        Text(
                          '${fmt.format(assignment.startDate!)} – '
                          '${fmt.format(assignment.endDate!)}',
                        ),
                    ],
                  ),
                ),
                StatusChip(label: labelForLevel(level), color: color),
              ],
            ),
            const SizedBox(height: 16),
            LabeledProgress(
              value: progress,
              color: color,
              caption: target > 0
                  ? '$total / $target ayat (${(progress * 100).round()}%)'
                  : 'Target ayat belum tersedia',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Hari ke-${day > GlobalConst.hariPerPeriode ? GlobalConst.hariPerPeriode : day} '
                  'dari ${GlobalConst.hariPerPeriode}',
                ),
                const Spacer(),
                if (remaining != null)
                  Text(
                    remaining >= 0
                        ? '$remaining hari tersisa'
                        : 'Lewat tenggat',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            if (reminder != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('📣 $reminder'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final SetoranAnggota? me;
  final VoidCallback? onSetor;

  const _TodayCard({this.me, this.onSetor});

  @override
  Widget build(BuildContext context) {
    final sudah = me?.sudahSetor ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  sudah ? Icons.check_circle : Icons.pending_actions,
                  color: sudah ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sudah
                        ? 'Sudah lapor hari ini (ayat ${me?.ayatFrom ?? '-'}–${me?.ayatTo ?? '-'})'
                        : 'Belum lapor hafalan hari ini',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (onSetor == null) ...[
              const SizedBox(height: 8),
              const Text(
                'Juz periode ini sudah ditutup. Juz berikutnya '
                'dibagikan otomatis saat periode baru dimulai.',
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSetor,
                icon: const Icon(Icons.edit_note),
                label: Text(sudah ? 'Perbarui Setoran' : 'Setor Hafalan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
