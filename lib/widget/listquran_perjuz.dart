import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class JuzAyahPage extends StatefulWidget {
  final int juzNumber;
  const JuzAyahPage({super.key, required this.juzNumber});

  @override
  State<JuzAyahPage> createState() => _JuzAyahPageState();
}

class _JuzAyahPageState extends State<JuzAyahPage> {
  List ayahs = [];
  bool isLoading = true;
  final AudioPlayer audioPlayer = AudioPlayer();

  Set<int> readAyahs = {};
  Set<int> markedAyahs = {};

  @override
  void initState() {
    super.initState();
    fetchAyahByJuz(widget.juzNumber);
  }

  Future<void> fetchAyahByJuz(int juzNumber) async {
    final urlArab = Uri.parse(
      'https://api.alquran.cloud/v1/juz/$juzNumber/ar.quranuthmani',
    );
    final urlTerjemah = Uri.parse(
      'https://api.alquran.cloud/v1/juz/$juzNumber/id.indonesian',
    );

    try {
      final responseArab = await http.get(urlArab);
      final responseTerjemah = await http.get(urlTerjemah);

      if (responseArab.statusCode == 200 &&
          responseTerjemah.statusCode == 200) {
        final dataArab = json.decode(responseArab.body);
        final dataTerjemah = json.decode(responseTerjemah.body);

        final List arabAyahs = dataArab['data']['ayahs'];
        final List terjemahAyahs = dataTerjemah['data']['ayahs'];

        List combined = [];
        for (int i = 0; i < arabAyahs.length; i++) {
          combined.add({
            'number': arabAyahs[i]['number'],
            'text': arabAyahs[i]['text'], // Arab
            'translation': terjemahAyahs[i]['text'], // Indonesia
            'surah': arabAyahs[i]['surah'],
            'numberInSurah': arabAyahs[i]['numberInSurah'],
          });
        }

        setState(() {
          ayahs = combined;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint('Error fetching data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error: $e');
    }
  }

  void playAudio(String url) async {
    try {
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juz ${widget.juzNumber}'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ayahs.length,
              itemBuilder: (context, index) {
                final ayah = ayahs[index];
                final ayahNumber = ayah['number'];
                final isRead = readAyahs.contains(ayahNumber);
                final isMarked = markedAyahs.contains(ayahNumber);

                return Card(
                  color: Colors.green[50],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Arab + Terjemahan
                        Text(
                          ayah['text'],
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ayah['translation'] ?? '',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Surah ${ayah['surah']['englishName']} : ${ayah['numberInSurah']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tombol aksi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (isRead) {
                                    readAyahs.remove(ayahNumber);
                                  } else {
                                    readAyahs.add(ayahNumber);
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRead
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              child: Text(
                                isRead ? 'Sudah dibaca' : 'Belum dibaca',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final audioUrl =
                                    'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${ayah['number']}.mp3';
                                playAudio(audioUrl);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[400],
                              ),
                              child: const Text('Play Suara'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (isMarked) {
                                    markedAyahs.remove(ayahNumber);
                                  } else {
                                    markedAyahs.add(ayahNumber);
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMarked
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              child: Text(isMarked ? 'Ditandai' : 'Tandai'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
