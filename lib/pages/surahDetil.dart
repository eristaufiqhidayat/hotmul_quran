import 'package:flutter/material.dart';

// ==== Dummy Model & API ====
// Ganti dengan model & API kamu
class Surah {
  final int number;
  final String name;
  final List<Verse> verses;
  Surah({required this.number, required this.name, required this.verses});
}

class Verse {
  final int inSurahNumber;
  final String text;
  Verse({required this.inSurahNumber, required this.text});
}

class QuranApi {
  static Future<Surah> fetchSurah(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    return Surah(
      number: id,
      name: "Al-Fatihah",
      verses: List.generate(
        7,
        (i) => Verse(inSurahNumber: i + 1, text: "Ayat ke-${i + 1}"),
      ),
    );
  }
}

// ==== Widget utama ====
class SurahDetil extends StatefulWidget {
  final int defaultSurahId;
  const SurahDetil({super.key, required this.defaultSurahId});

  @override
  State<SurahDetil> createState() => _SurahDetilState();
}

class _SurahDetilState extends State<SurahDetil> {
  late Future<Surah> futureSurah;
  final Set<int> _bookmarks = {};

  @override
  void initState() {
    super.initState();
    futureSurah = QuranApi.fetchSurah(widget.defaultSurahId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Surah>(
        future: futureSurah,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingSkeleton();
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Gagal memuat data surah.\n${snapshot.error}',
              onRetry: () {
                setState(() {
                  futureSurah = QuranApi.fetchSurah(widget.defaultSurahId);
                });
              },
            );
          }

          final surah = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureSurah = QuranApi.fetchSurah(surah.number);
              });
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _SurahHeaderCard(surah: surah)),
                SliverList.separated(
                  itemCount: surah.verses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final v = surah.verses[index];
                    final bookmarked = _bookmarks.contains(v.inSurahNumber);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _AyahTile(
                        ayah: v,
                        onShare: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur share belum diimplementasi.',
                              ),
                            ),
                          );
                        },
                        onPlay: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Putar audio ayat ${v.inSurahNumber} (stub).',
                              ),
                            ),
                          );
                        },
                        bookmarked: bookmarked,
                        onToggleBookmark: () {
                          setState(() {
                            if (bookmarked) {
                              _bookmarks.remove(v.inSurahNumber);
                            } else {
                              _bookmarks.add(v.inSurahNumber);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==== Widget pelengkap ====
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text("Coba Lagi")),
        ],
      ),
    );
  }
}

class _SurahHeaderCard extends StatelessWidget {
  final Surah surah;
  const _SurahHeaderCard({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        title: Text(surah.name, style: const TextStyle(fontSize: 20)),
        subtitle: Text("Jumlah ayat: ${surah.verses.length}"),
      ),
    );
  }
}

class _AyahTile extends StatelessWidget {
  final Verse ayah;
  final VoidCallback onShare;
  final VoidCallback onPlay;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;

  const _AyahTile({
    required this.ayah,
    required this.onShare,
    required this.onPlay,
    required this.bookmarked,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text("(${ayah.inSurahNumber}) ${ayah.text}"),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(icon: const Icon(Icons.share), onPressed: onShare),
            IconButton(icon: const Icon(Icons.play_arrow), onPressed: onPlay),
            IconButton(
              icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
              onPressed: onToggleBookmark,
            ),
          ],
        ),
      ),
    );
  }
}
