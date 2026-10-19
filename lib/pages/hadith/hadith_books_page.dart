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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final books = HadithBook.all
        .where(
          (b) =>
              q.isEmpty ||
              b.name.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();

    return Container(
      color: hadithPageBg,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Header(bookCount: HadithBook.all.length),
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
  }
}

class _Header extends StatelessWidget {
  final int bookCount;

  const _Header({required this.bookCount});

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
                  '$bookCount kitab hadits\n'
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
                    ],
                  ),
                ),
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
