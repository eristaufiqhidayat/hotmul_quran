import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/hadith_model.dart';
import 'package:hotmul_quran/pages/hadith/hadith_detail_page.dart';
import 'package:hotmul_quran/pages/hadith/hadith_style.dart';

/// Daftar hadits satu kitab, dimuat per bagian (kitab/bab) saat digulir.
class HadithListPage extends StatefulWidget {
  final HadithBook book;

  const HadithListPage({super.key, required this.book});

  @override
  State<HadithListPage> createState() => _HadithListPageState();
}

class _HadithListPageState extends State<HadithListPage> {
  /// Nomor bagian yang hilang berturut-turut sebelum dianggap akhir kitab.
  static const int _maxMisses = 3;

  final List<HadithSection> _sections = [];
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  int _nextSection = 0;
  int _misses = 0;
  bool _ended = false;
  bool _loading = false;
  bool _failed = false;
  bool _loadingAll = false;
  String _query = '';

  int? get _queryNumber => int.tryParse(_query);

  int get _loadedCount =>
      _sections.fold<int>(0, (sum, s) => sum + s.hadiths.length);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_query.isEmpty &&
          _scroll.position.pixels > _scroll.position.maxScrollExtent - 600) {
        _loadMore();
      }
    });
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || _ended) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      // Lewati bagian yang kosong supaya layar tidak berhenti tanpa isi.
      while (!_ended) {
        final number = _nextSection;
        try {
          final section = await HadithApi.fetchSection(widget.book.id, number);
          _nextSection++;
          _misses = 0;
          if (section.hadiths.isEmpty) continue;
          _sections.add(section);
          break;
        } on HadithNotFound {
          _nextSection++;
          // Bagian 0 (mukadimah) memang tidak selalu ada.
          if (number > 0 && ++_misses >= _maxMisses) _ended = true;
        }
      }
      if (!mounted) return;
      setState(() => _loading = false);
      // Isi layar sampai bisa digulir.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _query.isEmpty &&
            _scroll.hasClients &&
            _scroll.position.maxScrollExtent < 600) {
          _loadMore();
        }
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

  /// Muat seluruh kitab supaya pencarian kata mencakup semua hadits.
  Future<void> _loadAll() async {
    setState(() {
      _loadingAll = true;
      _failed = false;
    });
    while (mounted && !_ended && !_failed) {
      if (_loading) {
        // Tunggu permintaan yang sedang berjalan selesai dulu.
        await Future<void>.delayed(const Duration(milliseconds: 200));
        continue;
      }
      await _loadMore();
    }
    if (mounted) setState(() => _loadingAll = false);
  }

  void _openHadith(int number, [Hadith? hadith]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HadithDetailPage(
          book: widget.book,
          number: number,
          initial: hadith,
        ),
      ),
    );
  }

  bool _matches(Hadith h) {
    if (_query.isEmpty) return true;
    if (_queryNumber != null) return h.number.toString().startsWith(_query);
    return h.terjemah.toLowerCase().contains(_query.toLowerCase()) ||
        h.arab.contains(_query);
  }

  /// Baris daftar: judul bagian (String) atau hadits (Hadith).
  List<Object> get _rows {
    final rows = <Object>[];
    for (final s in _sections) {
      final hadiths = s.hadiths.where(_matches).toList();
      if (hadiths.isEmpty) continue;
      if (_query.isEmpty && s.title.isNotEmpty) rows.add(s.title);
      rows.addAll(hadiths);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hadithPageBg,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.book.name),
            Text(
              widget.book.arabicName,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green.shade700,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v.trim()),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                final n = _queryNumber;
                if (n != null && n >= 1) _openHadith(n);
              },
              decoration: InputDecoration(
                hintText: 'Cari nomor atau kata, mis. niat',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_sections.isEmpty && (_loading || (!_failed && !_ended))) {
      return const Center(
        child: CircularProgressIndicator(color: hadithGreenMid),
      );
    }
    if (_sections.isEmpty && _failed) {
      return HadithErrorView(
        message: 'Gagal memuat hadits.',
        onRetry: _loadMore,
      );
    }

    final rows = _rows;
    final header = <Widget>[];
    final n = _queryNumber;
    if (n != null) {
      if (n >= 1) {
        header.add(
          _ActionTile(
            icon: Icons.open_in_new,
            text: 'Buka hadits nomor $n',
            onTap: () => _openHadith(n),
          ),
        );
      }
    } else if (_query.isNotEmpty) {
      header.add(
        _InfoTile(
          text:
              '${rows.length} hasil dari ${formatNumber(_loadedCount)} '
              'hadits yang sudah dimuat.',
        ),
      );
      if (!_ended) {
        header.add(
          _loadingAll
              ? _InfoTile(
                  text:
                      'Memuat semua hadits… '
                      '${formatNumber(_loadedCount)} hadits dimuat',
                  progress: null,
                  busy: true,
                )
              : _ActionTile(
                  icon: Icons.manage_search,
                  text: 'Cari di seluruh kitab',
                  onTap: _loadAll,
                ),
        );
      }
    }

    final showFooter = _query.isEmpty && (!_ended || _failed);
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: header.length + rows.length + (showFooter ? 1 : 0),
      itemBuilder: (context, i) {
        if (i < header.length) return header[i];
        final idx = i - header.length;
        if (idx == rows.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: _failed
                  ? TextButton.icon(
                      onPressed: _loadMore,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Gagal memuat, coba lagi'),
                    )
                  : const CircularProgressIndicator(color: hadithGreenMid),
            ),
          );
        }
        final row = rows[idx];
        if (row is String) return _SectionTitle(title: row);
        final h = row as Hadith;
        return _HadithCard(
          hadith: h,
          bookName: widget.book.shortName,
          onTap: () => _openHadith(h.number, h),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.bookmark, size: 18, color: hadithGreenMid),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: hadithGreen,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final Hadith hadith;
  final String bookName;
  final VoidCallback onTap;

  const _HadithCard({
    required this.hadith,
    required this.bookName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.green.shade100),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hadithGreenSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'HR. $bookName no. ${hadith.number}',
                        style: const TextStyle(
                          color: hadithGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  hadith.arab,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.8,
                    color: hadithArabicInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hadith.terjemah.isEmpty
                      ? 'Terjemah belum tersedia'
                      : hadith.terjemah,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        color: hadithGreenSoft,
        child: ListTile(
          leading: Icon(icon, color: hadithGreen),
          title: Text(
            text,
            style: const TextStyle(
              color: hadithGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String text;
  final double? progress;
  final bool busy;

  const _InfoTile({required this.text, this.progress, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: TextStyle(color: Colors.grey.shade700)),
          if (progress != null || busy) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              color: hadithGreenMid,
              backgroundColor: hadithGreenSoft,
            ),
          ],
        ],
      ),
    );
  }
}
