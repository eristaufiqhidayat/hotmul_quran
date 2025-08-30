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

  // 🎵 Audio Surah (full 1 surah)
  final AudioPlayer _surahPlayer = AudioPlayer();
  bool _isSurahPlaying = false;

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

      // gabungkan arab + terjemah
      List<Map<String, dynamic>> hasil = [];
      for (int i = 0; i < ayatArab.length; i++) {
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

  // 🎵 Fungsi Play Surah Full
  Future<void> _toggleSurahPlay() async {
    final surahUrl =
        "https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${widget.number}.mp3";

    if (_isSurahPlaying) {
      await _surahPlayer.stop();
      setState(() => _isSurahPlaying = false);
    } else {
      await _surahPlayer.play(UrlSource(surahUrl));
      setState(() => _isSurahPlaying = true);

      // auto stop kalau selesai
      _surahPlayer.onPlayerComplete.listen((event) {
        setState(() => _isSurahPlaying = false);
      });
    }
  }

  @override
  void dispose() {
    _surahPlayer.dispose(); // hentikan player saat keluar halaman
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: Icon(_isSurahPlaying ? Icons.stop_circle : Icons.play_circle),
            tooltip: _isSurahPlaying ? "Stop Surah" : "Play Surah",
            onPressed: _toggleSurahPlay,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final v = verses[index];
                final textArab = v['arab'];
                final terjemah = v['terjemah'];
                final audioUrl = v['audio'];
                final ayahNumber = v['number'];

                final bookmarked = _bookmarks.contains(ayahNumber);

                return _AyahTile(
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
                  disablePlay:
                      _isSurahPlaying, // ⛔ disable ayat kalau surah full sedang play
                );
              },
            ),
    );
  }
}

class _AyahTile extends StatefulWidget {
  final String textArab;
  final String terjemah;
  final String audioUrl;
  final int ayahNumber;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;
  final bool disablePlay;

  const _AyahTile({
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
    if (widget.disablePlay)
      return; // ⛔ jangan play kalau full surah sedang jalan

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
    final text = '${widget.textArab}\n\n${widget.terjemah}';
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
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Arab
            Text(
              widget.textArab,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 22, fontFamily: 'Amiri'),
            ),
            const SizedBox(height: 8),
            // Terjemah
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.terjemah,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.blue),
                  onPressed: _shareAyah,
                  tooltip: "Bagikan",
                ),
                // Tombol Play
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    color: widget.disablePlay ? Colors.grey : Colors.blue,
                  ),
                  onPressed: widget.disablePlay ? null : _togglePlay,
                ),
                // Tombol Bookmark
                IconButton(
                  icon: Icon(
                    widget.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: widget.bookmarked ? Colors.amber : null,
                  ),
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
