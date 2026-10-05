import 'package:flutter/material.dart';
import 'package:hotmul_quran/core/hafalan_rules.dart';
import 'package:hotmul_quran/model/assignment_model.dart';
import 'package:hotmul_quran/repositories/hafalan_repo.dart';
import 'package:hotmul_quran/widget/appbar_widget.dart';
import 'package:hotmul_quran/widget/hafalan_widgets.dart';

/// Form laporan hafalan harian (BRD 4.3, SRS FR-03).
///
/// Argumen route opsional: `{'juz': int, 'target_ayat': int}`.
class SetoranHafalanPage extends StatefulWidget {
  const SetoranHafalanPage({super.key});

  @override
  State<SetoranHafalanPage> createState() => _SetoranHafalanPageState();
}

class _SetoranHafalanPageState extends State<SetoranHafalanPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = HafalanRepo();

  final ayatFromController = TextEditingController();
  final ayatToController = TextEditingController();
  final catatanController = TextEditingController();

  Assignment? _assignment;
  int _targetAyat = 0;
  bool _argsRead = false;
  bool isLoading = true;
  bool isSubmit = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadAssignment();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Isi default form sekali saja (dulu di build() sehingga input user
    // selalu tertimpa setiap rebuild).
    if (_argsRead) return;
    _argsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _targetAyat = int.tryParse(args['target_ayat']?.toString() ?? '') ?? 0;
      final juz = args['juz'];
      ayatFromController.text = '1';
      if (_targetAyat > 0) {
        ayatToController.text = '$_targetAyat';
        catatanController.text =
            'Setoran untuk Juz $juz, ayat 1 sampai $_targetAyat';
      }
    }
  }

  @override
  void dispose() {
    ayatFromController.dispose();
    ayatToController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  Future<void> loadAssignment() async {
    setState(() {
      isLoading = true;
      _error = null;
    });
    try {
      final a = await _repo.getActiveAssignment();
      if (!mounted) return;
      setState(() {
        _assignment = a;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        isLoading = false;
      });
    }
  }

  String? _validateRange() => HafalanRules.validateAyatRange(
    int.tryParse(ayatFromController.text.trim()),
    int.tryParse(ayatToController.text.trim()),
    maxAyat: _targetAyat,
  );

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    final a = _assignment;
    if (a == null) return;

    setState(() => isSubmit = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final msg = await _repo.submit(
        assignmentId: a.id,
        ayatFrom: int.parse(ayatFromController.text.trim()),
        ayatTo: int.parse(ayatToController.text.trim()),
        keterangan: catatanController.text.trim(),
      );
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isSubmit = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Setoran Hafalan"),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        message: _error!,
        onRetry: loadAssignment,
      );
    }
    final a = _assignment;
    if (a == null) {
      return const EmptyState(
        icon: Icons.event_busy,
        message:
            'Tidak ada juz aktif untuk dilaporkan.\nSetoran periode ini '
            'sudah selesai atau Anda belum mendapat jadwal.',
      );
    }

    final remaining = a.daysRemaining(DateTime.now());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Juz ${a.juzNumber}",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (remaining != null)
              Text(
                remaining >= 0
                    ? '$remaining hari menuju tenggat'
                    : 'Tenggat sudah lewat',
              ),
            if (_targetAyat > 0) Text('Target: $_targetAyat ayat'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ayatFromController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Ayat dari"),
                    validator: (_) => _validateRange(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: ayatToController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Ayat sampai"),
                    validator: (_) => _validateRange() == null ? null : '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Catatan (opsional)",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmit ? null : submit,
                child: isSubmit
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text("Kirim Setoran"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
