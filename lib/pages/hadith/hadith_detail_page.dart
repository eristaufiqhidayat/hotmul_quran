import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hotmul_quran/model/hadith_model.dart';
import 'package:hotmul_quran/pages/hadith/hadith_style.dart';

/// Satu hadits lengkap: teks Arab, terjemah, salin/bagikan, dan
/// navigasi ke hadits sebelum/sesudahnya.
class HadithDetailPage extends StatefulWidget {
  final HadithBook book;
  final int number;
  final Hadith? initial;

  const HadithDetailPage({
    super.key,
    required this.book,
    required this.number,
    this.initial,
  });

  @override
  State<HadithDetailPage> createState() => _HadithDetailPageState();
}

class _HadithDetailPageState extends State<HadithDetailPage> {
  late int _number;
  Hadith? _hadith;
  bool _loading = false;
  bool _failed = false;
  double _arabicSize = 26;

  @override
  void initState() {
    super.initState();
    _number = widget.number;
    if (widget.initial != null && widget.initial!.number == _number) {
      _hadith = widget.initial;
    } else {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final h = await HadithApi.fetchOne(widget.book.id, _number);
      if (!mounted) return;
      setState(() {
        _hadith = h;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _goTo(int number) {
    if (number < 1 || number > widget.book.available) return;
    setState(() {
      _number = number;
      _hadith = null;
    });
    _fetch();
  }

  String get _shareText {
    final h = _hadith!;
    return '${h.arab}\n\n${h.terjemah}\n\n(${widget.book.name} no. ${h.number})';
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Hadits disalin')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hadithPageBg,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        title: Text('${widget.book.shortName} no. $_number'),
        actions: [
          IconButton(
            tooltip: 'Perkecil teks Arab',
            icon: const Icon(Icons.text_decrease),
            onPressed: _arabicSize > 18
                ? () => setState(() => _arabicSize -= 2)
                : null,
          ),
          IconButton(
            tooltip: 'Perbesar teks Arab',
            icon: const Icon(Icons.text_increase),
            onPressed: _arabicSize < 40
                ? () => setState(() => _arabicSize += 2)
                : null,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: hadithGreen),
                  onPressed: _number > 1 ? () => _goTo(_number - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Sebelumnya'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: hadithGreenMid,
                  ),
                  onPressed: _number < widget.book.available
                      ? () => _goTo(_number + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Berikutnya'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading || (_hadith == null && !_failed)) {
      return const Center(
        child: CircularProgressIndicator(color: hadithGreenMid),
      );
    }
    if (_failed) {
      return HadithErrorView(message: 'Gagal memuat hadits.', onRetry: _fetch);
    }
    final h = _hadith!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [hadithGreen, hadithGreenMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hadits nomor ${h.number} dari '
                      '${formatNumber(widget.book.available)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Salin',
                color: Colors.white,
                icon: const Icon(Icons.copy),
                onPressed: _copy,
              ),
              IconButton(
                tooltip: 'Bagikan',
                color: Colors.white,
                icon: const Icon(Icons.share),
                onPressed: () => Share.share(_shareText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: SelectableText(
            h.arab,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: _arabicSize,
              height: 2.0,
              color: hadithArabicInk,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Terjemah',
          style: TextStyle(
            color: hadithGreen,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          h.terjemah,
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
      ],
    );
  }
}
