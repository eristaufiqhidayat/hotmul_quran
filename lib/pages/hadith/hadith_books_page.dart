import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/hadith_model.dart';
import 'package:hotmul_quran/pages/hadith/hadith_list_page.dart';
import 'package:hotmul_quran/pages/hadith/hadith_style.dart';

/// Tab Hadits: daftar kitab hadits yang bisa dibaca.
class HadithBooksPage extends StatefulWidget {
  const HadithBooksPage({super.key});

  @override
  State<HadithBooksPage> createState() => _HadithBooksPageState();
}

class _HadithBooksPageState extends State<HadithBooksPage> {
  late Future<List<HadithBook>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = HadithApi.fetchBooks();
  }

  void _reload() {
    setState(() => _future = HadithApi.fetchBooks());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: hadithPageBg,
      child: FutureBuilder<List<HadithBook>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: hadithGreenMid),
            );
          }
          if (snapshot.hasError) {
            return HadithErrorView(
              message: 'Gagal memuat daftar kitab hadits.',
              onRetry: _reload,
            );
          }
          final q = _query.toLowerCase();
          final books = snapshot.data!
              .where(
                (b) =>
                    q.isEmpty ||
                    b.name.toLowerCase().contains(q) ||
                    b.author.toLowerCase().contains(q),
              )
              .toList();
          final total = snapshot.data!.fold<int>(0, (s, b) => s + b.available);

          return RefreshIndicator(
            color: hadithGreenMid,
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _Header(bookCount: snapshot.data!.length, total: total),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v.trim()),
                    decoration: InputDecoration(
                      hintText: 'Cari kitab, mis. Bukhari',
                      prefixIcon: const Icon(Icons.search),
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
                if (books.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Kitab tidak ditemukan')),
                  ),
                for (final b in books) _BookCard(book: b),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int bookCount;
  final int total;

  const _Header({required this.bookCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [hadithGreen, hadithGreenMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hadits Nabi ﷺ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$bookCount kitab · ${formatNumber(total)} hadits\n'
                  'Teks Arab dan terjemah Indonesia',
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_stories, color: Colors.white54, size: 56),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final HadithBook book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.green.shade100),
        ),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HadithListPage(book: book)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: hadithGreenSoft,
                  child: Text(
                    book.shortName.isNotEmpty ? book.shortName[0] : '?',
                    style: const TextStyle(
                      color: hadithGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (book.author.isNotEmpty)
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatNumber(book.available)} hadits',
                        style: const TextStyle(
                          fontSize: 12,
                          color: hadithGreenMid,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (book.arabicName.isNotEmpty)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        book.arabicName,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 18,
                          color: hadithGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
