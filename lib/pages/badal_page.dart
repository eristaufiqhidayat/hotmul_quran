import 'package:flutter/material.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/core/tanggal_id.dart';
import 'package:hotmul_quran/model/badal_model.dart';
import 'package:hotmul_quran/repositories/brd_repo.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/hafalan_widgets.dart';

/// Penggantian (badal): ambil alih juz anggota yang tidak lapor >= 14 hari
/// atau terlambat, dan badge "Pengganti Aktif" (BRD FR-06, FR-07).
class BadalPage extends StatefulWidget {
  const BadalPage({super.key});

  @override
  State<BadalPage> createState() => _BadalPageState();
}

class _BadalPageState extends State<BadalPage> {
  final _repo = BrdRepo();
  late Future<BadalInfo> _future;
  String _name = '';

  @override
  void initState() {
    super.initState();
    _future = _repo.getBadal();
    getUser().then((n) {
      if (mounted) setState(() => _name = n ?? '');
    });
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.getBadal();
    });
    // error ditampilkan oleh FutureBuilder; jangan sampai jadi unhandled
    await _future.then((_) {}, onError: (_) {});
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _konfirmasiAmbil(KandidatBadal k) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ambil alih Juz ${k.juz}?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Kamu akan menggantikan ${k.name} untuk Juz ${k.juz}'
              '${k.endDate != null ? ' sampai ${TanggalId.pendek(k.endDate!)}' : ''}. '
              'Juz milikmu tetap berjalan, jadi targetmu bertambah satu juz.',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3DA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Color(0xFFB26A00)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kamu mendapat badge "Pengganti Aktif" dan grup akan diberi tahu.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Konfirmasi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    try {
      final msg = await _repo.ambilAlih(k.assignmentId);
      _snack(msg);
    } catch (e) {
      _snack(e.toString());
    }
    _reload();
  }

  Future<void> _batal(BadalSaya b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Batalkan badal Juz ${b.juz}?'),
        content: const Text('Badge dari badal ini juga dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      _snack(await _repo.batalBadal(b.id));
    } catch (e) {
      _snack(e.toString());
    }
    _reload();
  }

  Future<void> _setor(BadalSaya b) async {
    final result = await Navigator.pushNamed(
      context,
      '/setoran-hafalan',
      arguments: {'juz': b.juz, 'assignment_id': b.assignmentId},
    );
    if (result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: 'Penggantian (Badal)'),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<BadalInfo>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  EmptyState(
                    icon: Icons.cloud_off,
                    message: snap.error.toString(),
                    onRetry: _reload,
                  ),
                ],
              );
            }
            final info = snap.data!;
            final aktif = info.badalSaya.where((b) => b.aktif).toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _profil(info.jumlahBadge),
                const SizedBox(height: 12),
                if (aktif.isNotEmpty) ...[
                  _judul('Juz badal saya'),
                  for (final b in aktif) _kartuBadalSaya(b),
                  const SizedBox(height: 12),
                ],
                if (info.kandidat.isEmpty)
                  const EmptyState(
                    icon: Icons.verified_user_outlined,
                    message:
                        'Semua anggota grup masih aktif. Belum ada juz yang perlu diambil alih.',
                  )
                else ...[
                  _peringatan(info.kandidat.length),
                  const SizedBox(height: 12),
                  for (final k in info.kandidat)
                    _kartuKandidat(k, aktif.isEmpty),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _judul(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    ),
  );

  Widget _profil(int badge) {
    final inisial = _name.trim().isEmpty
        ? '?'
        : _name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((s) => s[0])
              .join()
              .toUpperCase();
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ThemeConfig.greenlogo,
          foregroundColor: Colors.white,
          child: Text(inisial),
        ),
        title: Text(
          _name.isEmpty ? 'Saya' : '$_name (kamu)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: badge > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: PenggantiAktifBadge(jumlah: badge),
                )
              : const Text('Belum punya badge Pengganti Aktif'),
        ),
      ),
    );
  }

  Widget _peringatan(int jumlah) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF9E3E0),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFF8E1C1C)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$jumlah juz anggota tidak aktif bisa diambil alih.',
            style: const TextStyle(color: Color(0xFF8E1C1C)),
          ),
        ),
      ],
    ),
  );

  Widget _kartuKandidat(KandidatBadal k, bool boleh) {
    final alasan = k.status == 'late'
        ? 'Terlambat'
        : 'Tidak lapor ${k.hariTidakLapor ?? '-'} hari';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ThemeConfig.late, width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFF3D9D6),
                  foregroundColor: ThemeConfig.late,
                  child: Text(
                    '${k.juz}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${k.name} · Juz ${k.juz}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '$alasan · progres ${k.progres}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA12020),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: boleh ? () => _konfirmasiAmbil(k) : null,
              child: Text(
                boleh
                    ? 'Ambil Alih Juz Ini'
                    : 'Selesaikan badal yang berjalan dulu',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuBadalSaya(BadalSaya b) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Juz ${b.juz}${b.originalName != null ? ' · menggantikan ${b.originalName}' : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LabeledProgress(
              value: b.progres / 100,
              color: ThemeConfig.warning,
              caption:
                  'Progres ${b.progres}%'
                  '${b.endDate != null ? ' · tenggat ${TanggalId.pendek(b.endDate!)}' : ''}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: () => _batal(b),
                  child: const Text('Batalkan'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _setor(b),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Setor Hafalan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge "Pengganti Aktif ×N" (BRD FR-07).
class PenggantiAktifBadge extends StatelessWidget {
  final int jumlah;
  const PenggantiAktifBadge({super.key, required this.jumlah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE7B5),
        border: Border.all(color: const Color(0xFFE8B947)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium,
            size: 14,
            color: Color(0xFF6B4200),
          ),
          const SizedBox(width: 4),
          Text(
            'Pengganti Aktif ×$jumlah',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B4200),
            ),
          ),
        ],
      ),
    );
  }
}
