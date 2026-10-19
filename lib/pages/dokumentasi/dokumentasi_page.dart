import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hotmul_quran/config/theme_config.dart';
import 'package:hotmul_quran/core/tanggal_id.dart';
import 'package:hotmul_quran/model/dokumentasi_model.dart';
import 'package:hotmul_quran/repositories/brd_repo.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/hafalan_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Repository dokumentasi khotaman grup: foto, video, audio maks 50 MB
/// per periode (BRD FR-08).
class DokumentasiPage extends StatefulWidget {
  const DokumentasiPage({super.key});

  @override
  State<DokumentasiPage> createState() => _DokumentasiPageState();
}

class _DokumentasiPageState extends State<DokumentasiPage> {
  static const int maksByte = 50 * 1024 * 1024;

  final _repo = BrdRepo();
  late Future<DokumentasiList> _future;
  bool _admin = false;
  int _userId = 0;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.getDokumentasi();
    _init();
  }

  Future<void> _init() async {
    final admin = await isAdmin();
    final id = int.tryParse(await getUser_id() ?? '') ?? 0;
    if (mounted) {
      setState(() {
        _admin = admin;
        _userId = id;
      });
    }
  }

  Future<void> _reload() async {
    setState(() => _future = _repo.getDokumentasi());
    await _future;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pilih(FileType type) async {
    final result = await FilePicker.pickFiles(type: type);
    final path = result?.files.single.path;
    if (path == null) return;

    final size = await File(path).length();
    if (size > maksByte) {
      _snack('Ukuran file ${_ukuran(size)}, maksimal 50 MB');
      return;
    }
    if (!mounted) return;

    final form = await showModalBottomSheet<_FormUpload>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormDokumentasi(
        namaFile: result!.files.single.name,
        ukuran: _ukuran(size),
      ),
    );
    if (form == null) return;

    setState(() => _uploading = true);
    try {
      final msg = await _repo.uploadDokumentasi(
        path: path,
        deskripsi: form.deskripsi,
        juz: form.juz,
        tanggal: form.tanggal,
      );
      _snack(msg);
      _reload();
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _buka(Dokumentasi d) async {
    final ok = await launchUrl(
      Uri.parse(d.url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) _snack('Tidak bisa membuka file');
  }

  Future<void> _hapus(Dokumentasi d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus dokumentasi?'),
        content: Text(d.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      _snack(await _repo.hapusDokumentasi(d.id));
    } catch (e) {
      _snack(e.toString());
    }
    _reload();
  }

  static String _ukuran(int byte) {
    if (byte >= 1024 * 1024) {
      return '${(byte / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} MB';
    }
    return '${(byte / 1024).ceil()} KB';
  }

  IconData _ikon(String jenis) => switch (jenis) {
    'audio' => Icons.music_note,
    'video' => Icons.videocam,
    _ => Icons.image,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(title: 'Dokumentasi Khotaman'),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<DokumentasiList>(
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
            final list = snap.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (list.batasUpload != null) _batas(list),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _tombolPilih(
                        Icons.photo_library,
                        'Foto/Video',
                        () => _pilih(FileType.media),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _tombolPilih(
                        Icons.audio_file,
                        'File Audio',
                        () => _pilih(FileType.audio),
                      ),
                    ),
                  ],
                ),
                if (_uploading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 4),
                  const Text('Mengunggah… jangan tutup halaman ini'),
                ],
                const SizedBox(height: 16),
                Text(
                  'Repository grup (${list.data.length} dokumentasi)',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (list.data.isEmpty)
                  const EmptyState(
                    icon: Icons.folder_open,
                    message: 'Belum ada dokumentasi khotaman.',
                  )
                else
                  for (final d in list.data) _item(d),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _batas(DokumentasiList list) {
    final sisa = DateUtils.dateOnly(
      list.batasUpload!,
    ).difference(DateUtils.dateOnly(DateTime.now())).inDays;
    final teks = sisa < 0
        ? 'Periode ${list.periodeAktif} sudah berakhir'
        : sisa == 0
        ? 'Batas upload khotaman Periode ${list.periodeAktif}: hari ini'
        : 'Batas upload khotaman Periode ${list.periodeAktif}: $sisa hari lagi';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3DA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Color(0xFFB26A00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(teks, style: const TextStyle(color: Color(0xFF5A3A00))),
          ),
        ],
      ),
    );
  }

  Widget _tombolPilih(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(88),
        side: const BorderSide(color: ThemeConfig.primaryDark, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: _uploading ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _item(Dokumentasi d) {
    final bolehHapus = _admin || d.userId == _userId;
    final meta = [
      _ukuran(d.size),
      if (d.juz != null) 'Juz ${d.juz}',
      if (d.periodIndex != null) 'Periode ${d.periodIndex}',
      if (d.tanggal != null) TanggalId.lengkap(d.tanggal!),
      if (d.uploader != null) d.uploader!,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _buka(d),
        onLongPress: bolehHapus ? () => _hapus(d) : null,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE6D2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_ikon(d.jenis), color: ThemeConfig.greenlogo),
        ),
        title: Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          d.deskripsi?.isNotEmpty == true ? '${d.deskripsi}\n$meta' : meta,
        ),
        isThreeLine: d.deskripsi?.isNotEmpty == true,
        trailing: bolehHapus
            ? IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _hapus(d),
              )
            : null,
      ),
    );
  }
}

class _FormUpload {
  final DateTime tanggal;
  final int? juz;
  final String deskripsi;
  _FormUpload(this.tanggal, this.juz, this.deskripsi);
}

class _FormDokumentasi extends StatefulWidget {
  final String namaFile;
  final String ukuran;
  const _FormDokumentasi({required this.namaFile, required this.ukuran});

  @override
  State<_FormDokumentasi> createState() => _FormDokumentasiState();
}

class _FormDokumentasiState extends State<_FormDokumentasi> {
  final _juz = TextEditingController();
  final _deskripsi = TextEditingController();
  DateTime _tanggal = DateTime.now();

  @override
  void dispose() {
    _juz.dispose();
    _deskripsi.dispose();
    super.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.namaFile,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('${widget.ukuran} dari maks. 50 MB'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(TanggalId.lengkap(_tanggal)),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _tanggal,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _tanggal = d);
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _juz,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Juz',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _deskripsi,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              hintText: 'Catatan acara khotaman',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              icon: const Icon(Icons.drive_folder_upload),
              label: const Text('Simpan ke Repository'),
              onPressed: () {
                final juz = int.tryParse(_juz.text.trim());
                Navigator.pop(
                  context,
                  _FormUpload(
                    _tanggal,
                    juz != null && juz >= 1 && juz <= 30 ? juz : null,
                    _deskripsi.text.trim(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
