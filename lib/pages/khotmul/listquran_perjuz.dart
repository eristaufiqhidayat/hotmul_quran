import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
//import 'package:hotmul_quran/main.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:hotmul_quran/widget/tombol_send_cek.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JuzAyahPage extends StatefulWidget {
  final int juzNumber;
  final int khotmulId;
  const JuzAyahPage({
    super.key,
    required this.juzNumber,
    required this.khotmulId,
  });

  @override
  State<JuzAyahPage> createState() => _JuzAyahPageState();
}

class _JuzAyahPageState extends State<JuzAyahPage> {
  List ayahs = [];
  bool isLoading = true;
  final AudioPlayer audioPlayer = AudioPlayer();
  var daurah_id;
  Set<int> readAyahs = {};
  Set<int> markedAyahs = {};
  var batalLapor = false;
  var status;

  @override
  void initState() {
    super.initState();
    loadReadAyahs();
    fetchAyahByJuz(widget.juzNumber);
    _loadDaurahId();
    _cekStatus();
  }

  // Load ayah yang sudah dibaca dari local storage
  Future<void> loadReadAyahs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('readAyahs_${widget.juzNumber}') ?? [];
    setState(() {
      readAyahs = saved.map((e) => int.parse(e)).toSet();
    });
  }

  void checkSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Mendapatkan semua keys yang tersimpan
    final allKeys = prefs.getKeys();

    print('Jumlah data: ${allKeys.length}');
    print('Keys yang tersimpan: $allKeys');

    // Menampilkan detail setiap key dan valuenya
    for (var key in allKeys) {
      final value = prefs.get(key);
      print('Key: $key, Value: $value, Type: ${value.runtimeType}');
    }
  }

  Future<void> _loadDaurahId() async {
    daurah_id = await getDaurah_id();
    //print(daurah_id);
    if (mounted) setState(() {});
  }

  Future<void> _cekStatus({int page = 1, String? search}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/khotmul?group_id=$daurah_id&page=$page&search=${search ?? ''}",
    );
    // print(
    //   "${GlobalConst.url}/api/v1/khotmul?group_id=$daurah_id&page=$page&search=${search ?? ''}",
    // );
    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        status = result['data'];
        cekStat();
      });
    }

    setState(() => isLoading = false);
  }

  // Simpan ayah yang sudah dibaca ke local storage
  Future<void> saveReadAyahs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'readAyahs_${widget.juzNumber}',
      readAyahs.map((e) => e.toString()).toList(),
    );
  }

  void cekStat() {
    //print(status);
    List<Map<String, dynamic>> data = status;

    var anggotaId = 100000213;
    var item = data.firstWhere(
      (e) => e["anggota_id"] == anggotaId,
      orElse: () => {},
    );

    if (item.isNotEmpty) {
      print("Status anggota $anggotaId adalah: ${item["status"]}");
    } else {
      print("Data anggota $anggotaId tidak ditemukan.");
    }
  }

  Future<void> updateStatus() async {
    final token = await getToken();
    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/khotmul/updateStatus/${widget.khotmulId.toString()}",
    );
    print(
      "${GlobalConst.url}/api/v1/khotmul/updateStatus/${widget.khotmulId.toString()}",
    );
    var payload = {"status": "send_voice"};

    if (batalLapor == true) {
      payload = {"status": "send_no"};
    }
    print(payload);
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // penting
      },
      body: jsonEncode(payload), // jadi JSON
    );
    //print(response.body);
    if (!mounted) return;
    if (response.statusCode == 200) {
      //Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sukses upload data")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal upload data")));
    }
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
            'text': arabAyahs[i]['text'],
            'translation': terjemahAyahs[i]['text'],
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

  void markAyahAsRead(int ayahNumber) async {
    setState(() {
      readAyahs.add(ayahNumber);
    });
    await saveReadAyahs();

    // Cek apakah semua sudah dibaca
    bool allRead = ayahs.every((ayah) => readAyahs.contains(ayah['number']));
    if (allRead) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cek All Read")));
    } else {
      batalLapor == true;
      updateStatus();
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  void toggleAllAyahs() async {
    setState(() {
      if (readAyahs.length == ayahs.length) {
        readAyahs.clear();
      } else {
        readAyahs.addAll(ayahs.map((a) => a['number']));
      }
    });
    await saveReadAyahs();

    bool allRead = ayahs.every((ayah) => readAyahs.contains(ayah['number']));
    if (allRead && ayahs.isNotEmpty) {
      if (!mounted) return; // ✅ Cek dulu
    } else {
      batalLapor = true;
      updateStatus();
    }
  }

  void toggleReadAyah(int ayahNumber) async {
    checkSharedPreferences();
    setState(() {
      if (readAyahs.contains(ayahNumber)) {
        readAyahs.remove(ayahNumber);
      } else {
        readAyahs.add(ayahNumber);
      }
    });
    await saveReadAyahs();

    bool allRead = ayahs.every((ayah) => readAyahs.contains(ayah['number']));
    if (allRead && ayahs.isNotEmpty) {
      if (!mounted) return; // ✅ jaga sebelum showDialog
      print("sukses $allRead");
    } else {
      setState(() {
        batalLapor = true;
        print(batalLapor);
        updateStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juz ${widget.juzNumber}'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: toggleAllAyahs,
            icon: Icon(
              readAyahs.length == ayahs.length
                  ? Icons
                        .clear_all // kalau sudah semua → tombol clear
                  : Icons.done_all, // kalau belum semua → tombol tandai semua
              color: Colors.white,
            ),
            tooltip: readAyahs.length == ayahs.length
                ? 'Hapus semua tanda baca'
                : 'Tandai semua sudah dibaca',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SendCheckButtons(
                  onSend: updateStatus,
                  onCheckAll: toggleAllAyahs,
                  allChecked: readAyahs.length == ayahs.length,
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: ayahs.length,
                    itemBuilder: (context, index) {
                      final ayah = ayahs[index];
                      final ayahNumber = ayah['number'];
                      final isRead = readAyahs.contains(ayahNumber);
                      //final isMarked = markedAyahs.contains(ayahNumber);

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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Icon "Sudah dibaca"
                                  IconButton(
                                    onPressed: () => toggleReadAyah(ayahNumber),
                                    icon: Icon(
                                      Icons.check_circle,
                                      color: isRead
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 28,
                                    ),
                                    tooltip: isRead
                                        ? 'Sudah dibaca'
                                        : 'Belum dibaca',
                                  ),

                                  // Icon "Play Suara"
                                  IconButton(
                                    onPressed: () {
                                      final audioUrl =
                                          'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${ayah['number']}.mp3';
                                      playAudio(audioUrl);
                                    },
                                    icon: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.green[400],
                                      size: 28,
                                    ),
                                    tooltip: 'Play Suara',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
