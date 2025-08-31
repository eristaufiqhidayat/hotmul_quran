import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

class SurahDetailPage extends StatefulWidget {
  final int number;
  final String name;

  const SurahDetailPage({super.key, required this.number, required this.name});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<Map<String, dynamic>> verses = [];
  bool loading = true;
  final Set<int> _bookmarks = {};
  final AudioPlayer _surahPlayer = AudioPlayer();
  bool _isSurahPlaying = false;

  String? bismillah;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final urlArab = Uri.parse(
        "https://api.alquran.cloud/v1/surah/${widget.number}/ar.alafasy",
      );
      final urlIndo = Uri.parse(
        "https://api.alquran.cloud/v1/surah/${widget.number}/id.indonesian",
      );

      final resArab = await http.get(urlArab);
      final resIndo = await http.get(urlIndo);

      final dataArab = json.decode(resArab.body);
      final dataIndo = json.decode(resIndo.body);

      final List ayatArab = dataArab['data']['ayahs'];
      final List ayatIndo = dataIndo['data']['ayahs'];

      List<Map<String, dynamic>> hasil = [];
      for (int i = 0; i < ayatArab.length; i++) {
        // Simpan Bismillah jika ada pada ayat pertama
        if (i == 0 && ayatArab[i]['text'].contains("بسم الله الرحمن الرحيم")) {
          bismillah = ayatArab[i]['text'];
          continue; // jangan masukkan sebagai ayat biasa
        }

        hasil.add({
          "number": ayatArab[i]['numberInSurah'],
          "arab": ayatArab[i]['text'],
          "terjemah": ayatIndo[i]['text'],
          "audio": ayatArab[i]['audio'],
        });
      }

      setState(() {
        verses = hasil;
        loading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => loading = false);
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

      _surahPlayer.onPlayerComplete.listen((event) {
        setState(() => _isSurahPlaying = false);
      });
    }
  }

  @override
  void dispose() {
    _surahPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: verses.length + (bismillah != null ? 1 : 0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                // tampilkan Bismillah di awal
                if (bismillah != null && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        bismillah!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                }

                final int verseIndex = bismillah != null ? index - 1 : index;
                final v = verses[verseIndex];
                final textArab = v['arab'];
                final terjemah = v['terjemah'];
                final audioUrl = v['audio'];
                final ayahNumber = v['number'];

                final bookmarked = _bookmarks.contains(ayahNumber);

                return _AyahTile(
                  surahNumber: widget.number,
                  textArab: textArab,
                  terjemah: terjemah,
                  audioUrl: audioUrl,
                  ayahNumber: ayahNumber,
                  bookmarked: bookmarked,
                  onToggleBookmark: () {
                    setState(() {
                      if (bookmarked) {
                        _bookmarks.remove(ayahNumber);
                      } else {
                        _bookmarks.add(ayahNumber);
                      }
                    });
                  },
                  disablePlay: _isSurahPlaying,
                );
              },
            ),
    );
  }
}

// -------------------- AYAH TILE --------------------
class _AyahTile extends StatefulWidget {
  final int surahNumber;
  final String textArab;
  final String terjemah;
  final String audioUrl;
  final int ayahNumber;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;
  final bool disablePlay;

  const _AyahTile({
    required this.surahNumber,
    required this.textArab,
    required this.terjemah,
    required this.audioUrl,
    required this.ayahNumber,
    required this.bookmarked,
    required this.onToggleBookmark,
    required this.disablePlay,
  });

  @override
  State<_AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends State<_AyahTile> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _togglePlay() async {
    if (widget.disablePlay) return;

    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(UrlSource(widget.audioUrl));
      setState(() => _isPlaying = true);

      _player.onPlayerComplete.listen((event) {
        setState(() => _isPlaying = false);
      });
    }
  }

  Future<void> _shareAyah() async {
    final text =
        'Surah ${widget.surahNumber}, Ayat ${widget.ayahNumber}\n\n${widget.textArab}\n\n${widget.terjemah}';
    await Share.share(text);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade700, width: 1.5),
      ),
      color: Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Nomor surah & ayat
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Surah ${widget.surahNumber} | Ayat ${widget.ayahNumber}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Teks Arab
            Text(
              widget.textArab,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Terjemahan
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.terjemah,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            // Row tombol: share, play, bookmark
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.share),
                  color: Colors.blue.shade700,
                  onPressed: _shareAyah,
                  tooltip: "Bagikan",
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  color: widget.disablePlay
                      ? Colors.grey
                      : Colors.green.shade700,
                  onPressed: widget.disablePlay ? null : _togglePlay,
                ),
                IconButton(
                  icon: Icon(
                    widget.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  color: widget.bookmarked
                      ? Colors.orange.shade700
                      : Colors.green.shade400,
                  onPressed: widget.onToggleBookmark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
