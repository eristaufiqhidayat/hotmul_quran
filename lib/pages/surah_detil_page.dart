import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hotmul_quran/core/tajweed.dart';

const String _quranFont = 'AmiriQuran';
const Color _green = Color(0xFF1B5E20);
const Color _greenMid = Color(0xFF2E7D32);
const Color _greenSoft = Color(0xFFE8F5E9);
const Color _pageBg = Color(0xFFF4F7F2);
const Color _arabicInk = Color(0xFF1C1C1C);

class SurahDetailPage extends StatefulWidget {
  final int number;
  final String name;

  const SurahDetailPage({super.key, required this.number, required this.name});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<_Verse> verses = [];
  bool loading = true;
  bool failed = false;
  final Set<int> _bookmarks = {};
  final AudioPlayer _surahPlayer = AudioPlayer();
  StreamSubscription<void>? _surahCompleteSub;
  bool _isSurahPlaying = false;

  String? _arabicName;
  String? _revelation;
  int? _ayahCount;

  /// Al-Fatihah menjadikan basmalah ayat pertama, At-Taubah tanpa basmalah.
  bool get _showBismillahHeader => widget.number != 1 && widget.number != 9;

  @override
  void initState() {
    super.initState();
    _surahCompleteSub = _surahPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isSurahPlaying = false);
    });
    fetchDetail();
  }

  Future<dynamic> _getJson(String url) async {
    final res = await http.get(Uri.parse(url));
    return json.decode(res.body);
  }

  Future<void> fetchDetail() async {
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      final base = "https://api.alquran.cloud/v1/surah/${widget.number}";
      final results = await Future.wait([
        _getJson("$base/ar.alafasy"),
        _getJson("$base/id.indonesian"),
        // Teks tajwid opsional: jika gagal, pakai teks Utsmani biasa.
        _getJson("$base/quran-tajweed").catchError((_) => null),
      ]);

      final dataArab = results[0]['data'];
      final List ayatArab = dataArab['ayahs'];
      final List ayatIndo = results[1]['data']['ayahs'];
      final tajweedData = results[2] is Map ? results[2]['data'] : null;
      final List? ayatTajweed = tajweedData is Map
          ? tajweedData['ayahs'] as List?
          : null;

      final hasil = <_Verse>[];
      for (int i = 0; i < ayatArab.length; i++) {
        final String raw = (ayatTajweed != null && i < ayatTajweed.length)
            ? ayatTajweed[i]['text']
            : ayatArab[i]['text'];
        var segments = Tajweed.parse(raw);
        if (i == 0 && _showBismillahHeader) {
          segments = Tajweed.stripLeadingBismillah(segments);
        }
        hasil.add(
          _Verse(
            number: ayatArab[i]['numberInSurah'],
            segments: segments,
            terjemah: ayatIndo[i]['text'],
            audio: ayatArab[i]['audio'],
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        verses = hasil;
        _arabicName = dataArab['name'];
        _revelation = dataArab['revelationType'];
        _ayahCount = dataArab['numberOfAyahs'];
        loading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      if (!mounted) return;
      setState(() {
        loading = false;
        failed = true;
      });
    }
  }

  Future<void> _toggleSurahPlay() async {
    final surahUrl =
        "https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${widget.number}.mp3";

    if (_isSurahPlaying) {
      await _surahPlayer.stop();
      setState(() => _isSurahPlaying = false);
    } else {
      await _surahPlayer.play(UrlSource(surahUrl));
      setState(() => _isSurahPlaying = true);
    }
  }

  @override
  void dispose() {
    _surahCompleteSub?.cancel();
    _surahPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: Icon(_isSurahPlaying ? Icons.stop_circle : Icons.play_circle),
            tooltip: _isSurahPlaying ? "Stop Surah" : "Play Surah",
            color: Colors.white,
            onPressed: _toggleSurahPlay,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: _greenMid));
    }
    if (failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade500),
              const SizedBox(height: 12),
              const Text(
                "Gagal memuat surah. Periksa koneksi internet.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _greenMid),
                onPressed: fetchDetail,
                icon: const Icon(Icons.refresh),
                label: const Text("Coba lagi"),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: verses.length + 2,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _SurahHeader(
            latinName: widget.name,
            arabicName: _arabicName,
            number: widget.number,
            revelation: _revelation,
            ayahCount: _ayahCount ?? verses.length,
            showBismillah: _showBismillahHeader,
          );
        }
        if (index == 1) return const _TajweedLegend();

        final v = verses[index - 2];
        final bookmarked = _bookmarks.contains(v.number);
        return _AyahTile(
          surahNumber: widget.number,
          verse: v,
          bookmarked: bookmarked,
          onToggleBookmark: () {
            setState(() {
              if (bookmarked) {
                _bookmarks.remove(v.number);
              } else {
                _bookmarks.add(v.number);
              }
            });
          },
          disablePlay: _isSurahPlaying,
        );
      },
    );
  }
}

class _Verse {
  final int number;
  final List<TajweedSegment> segments;
  final String terjemah;
  final String audio;

  const _Verse({
    required this.number,
    required this.segments,
    required this.terjemah,
    required this.audio,
  });

  String get arabPlain => segments.map((s) => s.text).join().trim();
}

// -------------------- HEADER SURAH --------------------
class _SurahHeader extends StatelessWidget {
  final String latinName;
  final String? arabicName;
  final int number;
  final String? revelation;
  final int ayahCount;
  final bool showBismillah;

  const _SurahHeader({
    required this.latinName,
    required this.arabicName,
    required this.number,
    required this.revelation,
    required this.ayahCount,
    required this.showBismillah,
  });

  @override
  Widget build(BuildContext context) {
    final tempat = switch (revelation) {
      'Meccan' => 'Makkiyah',
      'Medinan' => 'Madaniyah',
      _ => null,
    };
    final info = ['Surah ke-$number', ?tempat, '$ayahCount Ayat'].join('  •  ');

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF66BB6A)],
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          if (arabicName != null)
            Text(
              arabicName!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: _quranFont,
                fontSize: 30,
                height: 2.0,
                color: Colors.white,
              ),
            ),
          if (arabicName != null) const SizedBox(height: 6),
          Text(
            latinName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (showBismillah) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(child: _ornamentLine()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Expanded(child: _ornamentLine()),
                ],
              ),
            ),
            const Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _quranFont,
                fontSize: 26,
                height: 1.9,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ornamentLine() =>
      Container(height: 1, color: Colors.white.withValues(alpha: 0.5));
}

// -------------------- PANDUAN WARNA TAJWID --------------------
class _TajweedLegend extends StatelessWidget {
  const _TajweedLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: _greenMid,
          collapsedIconColor: _greenMid,
          leading: const Icon(Icons.palette_outlined, color: _greenMid),
          title: const Text(
            'Panduan warna tajwid',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _green,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final code in Tajweed.legendCodes)
                    _LegendChip(rule: Tajweed.rules[code]!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final TajweedRule rule;

  const _LegendChip({required this.rule});

  @override
  Widget build(BuildContext context) {
    final label = rule.code == 'h' ? 'Tidak dibaca / Washal' : rule.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: rule.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: rule.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- AYAH TILE --------------------
class _AyahTile extends StatefulWidget {
  final int surahNumber;
  final _Verse verse;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;
  final bool disablePlay;

  const _AyahTile({
    required this.surahNumber,
    required this.verse,
    required this.bookmarked,
    required this.onToggleBookmark,
    required this.disablePlay,
  });

  @override
  State<_AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends State<_AyahTile> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completeSub;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _togglePlay() async {
    if (widget.disablePlay) return;

    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(UrlSource(widget.verse.audio));
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _shareAyah() async {
    final v = widget.verse;
    final text =
        'Surah ${widget.surahNumber}, Ayat ${v.number}\n\n${v.arabPlain}\n\n${v.terjemah}';
    await Share.share(text);
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.verse;
    const arabicStyle = TextStyle(
      fontFamily: _quranFont,
      fontSize: 26,
      height: 2.1,
      color: _arabicInk,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: _isPlaying ? const Color(0xFFF1F8E9) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isPlaying
              ? Colors.green.shade400
              : widget.bookmarked
              ? Colors.orange.shade300
              : Colors.green.shade100,
          width: _isPlaying || widget.bookmarked ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baris atas: nomor ayat + tombol aksi
          Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
            decoration: const BoxDecoration(
              color: _greenSoft,
              borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              children: [
                _AyahBadge(number: v.number),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ayat ${v.number}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _green,
                    ),
                  ),
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  tooltip: "Bagikan",
                  color: _greenMid,
                  onPressed: _shareAyah,
                ),
                _ActionButton(
                  icon: _isPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  tooltip: _isPlaying ? "Stop" : "Putar",
                  color: widget.disablePlay ? Colors.grey : _greenMid,
                  onPressed: widget.disablePlay ? null : _togglePlay,
                ),
                _ActionButton(
                  icon: widget.bookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  tooltip: "Tandai",
                  color: widget.bookmarked ? Colors.orange.shade700 : _greenMid,
                  onPressed: widget.onToggleBookmark,
                ),
              ],
            ),
          ),
          // Teks Arab dengan warna tajwid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text.rich(
              TextSpan(
                style: arabicStyle,
                children: [
                  for (final s in v.segments)
                    TextSpan(
                      text: s.text,
                      style: s.rule == null
                          ? null
                          : TextStyle(color: s.rule!.color),
                    ),
                  // Tanda akhir ayat ۝ dengan nomor Arab
                  TextSpan(
                    text: ' ۝${Tajweed.arabicNumber(v.number)}',
                    style: const TextStyle(color: _greenMid),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 16, color: Colors.green.shade50),
          ),
          // Terjemahan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              v.terjemah,
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      color: color,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

/// Lencana nomor ayat berbentuk bintang segi delapan (rub el hizb).
class _AyahBadge extends StatelessWidget {
  final int number;

  const _AyahBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    Widget square(double angle) => Transform.rotate(
      angle: angle,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: _greenMid,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );

    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          square(0),
          square(math.pi / 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '$number',
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
