import 'package:flutter/material.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/core/hijri.dart';
import 'package:hotmul_quran/core/tanggal_id.dart';
import 'package:hotmul_quran/model/jadwal_bergulir_model.dart';
import 'package:hotmul_quran/repositories/brd_repo.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/hafalan_widgets.dart';

/// Jadwal bergulir anggota: kalender 14 hari periode berjalan (Masehi +
/// Hijriah), riwayat juz, dan juz berikutnya (BRD FR-02, 4.6).
class JadwalBergulirPage extends StatefulWidget {
  const JadwalBergulirPage({super.key});

  @override
  State<JadwalBergulirPage> createState() => _JadwalBergulirPageState();
}

class _JadwalBergulirPageState extends State<JadwalBergulirPage> {
  late Future<JadwalBergulir> _future;
  bool _hijriSaja = false;

  @override
  void initState() {
    super.initState();
    _future = BrdRepo().getJadwalBergulir();
  }

  Future<void> _reload() async {
    setState(() => _future = BrdRepo().getJadwalBergulir());
    await _future;
  }

  String _rentang(JadwalJuz j) {
    if (j.startDate == null || j.endDate == null) return '-';
    final masehi =
        '${TanggalId.pendek(j.startDate!)} – ${TanggalId.pendek(j.endDate!)}';
    final h1 = HijriDate.fromDate(j.startDate!);
    final h2 = HijriDate.fromDate(j.endDate!);
    final hijri = h1.month == h2.month
        ? '${h1.day}–${h2.day} ${h2.monthName} ${h2.year} H'
        : '${h1.day} ${h1.monthName} – $h2';
    return _hijriSaja ? hijri : '$masehi · $hijri';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: 'Jadwal Bergulir'),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<JadwalBergulir>(
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
            final data = snap.data!;
            if (data.sekarang == null) {
              return ListView(
                children: const [
                  EmptyState(
                    icon: Icons.event_busy,
                    message:
                        'Belum ada jadwal juz. Admin perlu memasukkan Anda ke grup.',
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Masehi + Hijriah'),
                    ),
                    ButtonSegment(value: true, label: Text('Hijriah saja')),
                  ],
                  selected: {_hijriSaja},
                  onSelectionChanged: (v) =>
                      setState(() => _hijriSaja = v.first),
                ),
                const SizedBox(height: 14),
                _kalender(data),
                const SizedBox(height: 20),
                Text(
                  'Riwayat & jadwal berikutnya',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      for (final j in data.riwayat) _barisJuz(j),
                      for (final j in data.berikutnya) _barisJuz(j),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _kalender(JadwalBergulir data) {
    final s = data.sekarang!;
    final status = assignmentStatusStyle(s.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode ${s.periodIndex} · Juz ${s.juz}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _rentang(s),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusChip(label: status.label, color: status.color),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.8,
              children: [for (final h in data.hari) _sel(h)],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                _legenda(ThemeConfig.onTrack, 'Sudah lapor'),
                _legenda(ThemeConfig.primaryDark, 'Hari ini', outline: true),
                _legenda(const Color(0xFFF7E9C9), 'H-3 / H-1 tenggat'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sel(JadwalHari h) {
    var bg = Colors.white;
    var fg = Colors.black87;
    if (h.tenggat) {
      bg = const Color(0xFFF7E9C9);
      fg = const Color(0xFF6B4200);
    }
    if (h.sudahLapor) {
      bg = ThemeConfig.onTrack;
      fg = Colors.white;
    }
    final hijri = HijriDate.fromDate(h.tanggal);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: h.hariIni ? ThemeConfig.primaryDark : const Color(0xFFE3E5D9),
          width: h.hariIni ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            TanggalId.namaHari(h.tanggal),
            style: TextStyle(fontSize: 9, color: fg.withValues(alpha: 0.8)),
          ),
          Text(
            _hijriSaja ? '${hijri.day}' : '${h.tanggal.day}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
          if (!_hijriSaja)
            Text(
              '${hijri.day}',
              style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.85)),
            ),
        ],
      ),
    );
  }

  Widget _legenda(Color c, String label, {bool outline = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: outline ? null : c,
            border: outline ? Border.all(color: c, width: 2) : null,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _barisJuz(JadwalJuz j) {
    final terjadwal = j.status == 'terjadwal';
    final st = terjadwal
        ? (label: 'Terjadwal', color: ThemeConfig.neutral)
        : assignmentStatusStyle(j.status);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: st.color.withValues(alpha: 0.15),
        foregroundColor: st.color,
        child: Text(
          '${j.juz}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text('Periode ${j.periodIndex}: Juz ${j.juz}'),
      subtitle: Text(_rentang(j)),
      trailing: Text(
        st.label,
        style: TextStyle(color: st.color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
