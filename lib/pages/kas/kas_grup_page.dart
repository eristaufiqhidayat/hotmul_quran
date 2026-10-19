
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/core/tanggal_id.dart';
import 'package:hotmul_quran/model/kas_model.dart';
import 'package:hotmul_quran/repositories/assignment_repo.dart';
import 'package:hotmul_quran/repositories/brd_repo.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/hafalan_widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Kas grup: saldo, sumbangan, pengeluaran, verifikasi admin, dan ekspor
/// laporan (BRD FR-09). Menggantikan menu Donasi lama.
class KasGrupPage extends StatefulWidget {
  const KasGrupPage({super.key});

  @override
  State<KasGrupPage> createState() => _KasGrupPageState();
}

class _KasGrupPageState extends State<KasGrupPage> {
  final _repo = BrdRepo();
  late Future<KasRingkasan> _future;
  bool _admin = false;
  int? _periodeAktif;

  /// null = semua periode
  int? _filterPeriode;

  @override
  void initState() {
    super.initState();
    _future = _repo.getKas();
    _init();
  }

  Future<void> _init() async {
    final admin = await isAdmin();
    final periode = await AssignmentRepo().getPeriodeActive();
    if (!mounted) return;
    setState(() {
      _admin = admin;
      _periodeAktif = int.tryParse(
        (periode?['data'] as Map?)?['periode']?.toString() ?? '',
      );
    });
  }

  Future<void> _reload() async {
    setState(() => _future = _repo.getKas(periode: _filterPeriode));
    await _future;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _export() async {
    try {
      final bytes = await _repo.exportKas(periode: _filterPeriode);
      final nama = _filterPeriode == null
          ? 'kas-grup.csv'
          : 'kas-grup-periode-$_filterPeriode.csv';
      await Share.shareXFiles([
        XFile.fromData(
          Uint8List.fromList(bytes),
          name: nama,
          mimeType: 'text/csv',
        ),
      ], subject: 'Laporan kas grup');
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _tambah({String metodeAwal = 'Manual'}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormKas(admin: _admin, metodeAwal: metodeAwal),
    );
    if (saved == true) _reload();
  }

  Future<void> _aksi(KasTransaksi t) async {
    final bolehHapus = _admin || !t.isVerified;
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_admin && !t.isVerified)
              ListTile(
                leading: const Icon(Icons.verified, color: ThemeConfig.onTrack),
                title: const Text('Verifikasi sumbangan'),
                onTap: () => Navigator.pop(context, 'verif'),
              ),
            if (bolehHapus)
              ListTile(
                leading: const Icon(Icons.delete, color: ThemeConfig.late),
                title: const Text('Hapus transaksi'),
                onTap: () => Navigator.pop(context, 'hapus'),
              ),
          ],
        ),
      ),
    );
    try {
      if (pilihan == 'verif') {
        _snack(await _repo.verifikasiKas(t.id));
      } else if (pilihan == 'hapus') {
        _snack(await _repo.hapusKas(t.id));
      } else {
        return;
      }
    } catch (e) {
      _snack(e.toString());
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: 'Kas Grup',
        leading: [
          IconButton(
            tooltip: 'Ekspor ke Excel (CSV)',
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _export,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<KasRingkasan>(
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
            final kas = snap.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _saldo(kas),
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: ThemeConfig.warning,
                      foregroundColor: const Color(0xFF2B1D00),
                    ),
                    onPressed: () => _tambah(),
                    icon: const Icon(Icons.add),
                    label: Text(
                      _admin ? 'Catat Transaksi' : 'Tambah Sumbangan',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final m in _FormKas.metode) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _tambah(metodeAwal: m),
                          child: Text(m),
                        ),
                      ),
                      if (m != _FormKas.metode.last) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Riwayat transaksi',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Semua'),
                      selected: _filterPeriode == null,
                      onSelected: (_) {
                        _filterPeriode = null;
                        _reload();
                      },
                    ),
                    if (_periodeAktif != null) ...[
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text('Periode $_periodeAktif'),
                        selected: _filterPeriode == _periodeAktif,
                        onSelected: (_) {
                          _filterPeriode = _periodeAktif;
                          _reload();
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (kas.data.isEmpty)
                  const EmptyState(
                    icon: Icons.receipt_long,
                    message: 'Belum ada transaksi.',
                  )
                else
                  Card(
                    child: Column(
                      children: [for (final t in kas.data) _baris(t)],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _saldo(KasRingkasan kas) {
    const sub = TextStyle(color: Color(0xFFD4E8CC), fontSize: 13);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo terkini${kas.groupName != null ? ' · ${kas.groupName}' : ''}',
            style: sub,
          ),
          const SizedBox(height: 4),
          Text(
            TanggalId.rupiah(kas.saldo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _filterPeriode == null
                        ? 'Total masuk'
                        : 'Masuk periode ini',
                    style: sub,
                  ),
                  Text(
                    '+ ${TanggalId.rupiah(kas.masuk)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keluar', style: sub),
                  Text(
                    '− ${TanggalId.rupiah(kas.keluar)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          if (kas.menungguVerifikasi > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${kas.menungguVerifikasi} sumbangan menunggu verifikasi admin',
              style: sub,
            ),
          ],
        ],
      ),
    );
  }

  Widget _baris(KasTransaksi t) {
    final warna = t.masuk ? const Color(0xFF1E6B22) : const Color(0xFFA12020);
    final nama = t.masuk
        ? (t.name ?? '-')
        : (t.keterangan?.isNotEmpty == true ? t.keterangan! : 'Pengeluaran');
    final meta = [
      if (t.tanggal != null) TanggalId.lengkap(t.tanggal!),
      if (!t.masuk) 'pengeluaran' else if (t.metode != null) t.metode!,
      if (!t.isVerified) 'menunggu verifikasi',
    ].join(' · ');
    return ListTile(
      onTap: () => _aksi(t),
      leading: CircleAvatar(
        backgroundColor: warna.withValues(alpha: 0.15),
        foregroundColor: warna,
        child: Text(
          t.masuk && nama.length >= 2
              ? nama.substring(0, 2).toUpperCase()
              : '−',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      title: Text(nama),
      subtitle: Text(meta),
      trailing: Text(
        '${t.masuk ? '+' : '−'} ${TanggalId.rupiah(t.nominal)}',
        style: TextStyle(
          color: t.isVerified ? warna : ThemeConfig.neutral,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FormKas extends StatefulWidget {
  static const metode = ['QRIS', 'DANA', 'OVO', 'Manual'];

  final bool admin;
  final String metodeAwal;

  const _FormKas({required this.admin, required this.metodeAwal});

  @override
  State<_FormKas> createState() => _FormKasState();
}

class _FormKasState extends State<_FormKas> {
  final _formKey = GlobalKey<FormState>();
  final _nominal = TextEditingController();
  final _keterangan = TextEditingController();
  late String _metode = widget.metodeAwal;
  String _jenis = 'masuk';
  DateTime _tanggal = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _nominal.dispose();
    _keterangan.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final msg = await BrdRepo().tambahKas(
        jenis: _jenis,
        tanggal: _tanggal,
        nominal: int.parse(_nominal.text.replaceAll('.', '')),
        metode: _jenis == 'masuk' ? _metode : null,
        keterangan: _keterangan.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _jenis == 'masuk' ? 'Tambah Sumbangan' : 'Catat Pengeluaran',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (widget.admin) ...[
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'masuk', label: Text('Pemasukan')),
                    ButtonSegment(value: 'keluar', label: Text('Pengeluaran')),
                  ],
                  selected: {_jenis},
                  onSelectionChanged: (v) => setState(() => _jenis = v.first),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nominal,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (int.tryParse(v ?? '') ?? 0) < 1 ? 'Isi nominal' : null,
              ),
              const SizedBox(height: 12),
              if (_jenis == 'masuk') ...[
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in _FormKas.metode)
                      ChoiceChip(
                        label: Text(m),
                        selected: _metode == m,
                        onSelected: (_) => setState(() => _metode = m),
                      ),
                  ],
                ),
                if (_metode == 'QRIS') ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/barcode.jpeg', height: 220),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scan QR di atas, lalu simpan sumbangan ini.',
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text('Tanggal: ${TanggalId.lengkap(_tanggal)}'),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _tanggal,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (d != null) setState(() => _tanggal = d);
                },
              ),
              TextFormField(
                controller: _keterangan,
                decoration: InputDecoration(
                  labelText: _jenis == 'masuk'
                      ? 'Keterangan (opsional)'
                      : 'Untuk keperluan apa?',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => _jenis == 'keluar' && (v ?? '').trim().isEmpty
                    ? 'Isi keterangan pengeluaran'
                    : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _saving ? null : _simpan,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ),
              if (!widget.admin) ...[
                const SizedBox(height: 8),
                const Text(
                  'Sumbangan masuk ke saldo setelah diverifikasi admin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
