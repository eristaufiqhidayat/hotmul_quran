import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

class RecorderPage extends StatefulWidget {
  final int khotmulId;

  const RecorderPage({
    super.key,
    required this.khotmulId, // wajib diisi
  });

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final AudioRecorder _record = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;
  int currentPage = 1;
  int lastPage = 1;
  List<dynamic> anggota = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  var anggota_id;
  Future<void> fetchData({int page = 1, String? search}) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await getValidAccessToken();

    if (token == null) {
      await logout();
      return;
    }

    final url = Uri.parse(
      "${GlobalConst.url}/api/v1/khotmulrec/${widget.khotmulId}?page=$page&search=${search ?? ''}",
    );
    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    //print(response.body);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        anggota = result['data'];
        currentPage = result['current_page'];
        lastPage = result['last_page'];
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> _startRecording() async {
    try {
      if (await _record.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _record.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _filePath = filePath;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();
    setState(() {
      _isRecording = false;
      _filePath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_filePath != null) {
      try {
        await _player.play(DeviceFileSource(_filePath!));
        setState(() {
          _isPlaying = true;
        });
        _player.onPlayerComplete.listen((event) {
          setState(() {
            _isPlaying = false;
          });
        });
      } catch (e) {
        debugPrint("Error playing: $e");
      }
    }
  }

  Future<void> _shareRecording() async {
    if (_filePath != null) {
      try {
        await Share.shareXFiles([XFile(_filePath!)], text: 'Recorded Audio');
      } catch (e) {
        debugPrint("Error sharing: $e");
      }
    }
  }

  @override
  void dispose() {
    _record.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> saveRecording() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/khotmulrec/upload");

    var request = http.MultipartRequest("POST", url);

    // Tambahkan header
    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    // Tambahkan file (pastikan _filePath adalah path ke file yang valid)
    if (_filePath != null) {
      request.files.add(await http.MultipartFile.fromPath("file", _filePath!));
    }
    request.fields['khotmul_id'] = widget.khotmulId.toString();
    request.fields['juz'] = '1';
    request.fields['surah'] = '1';
    request.fields['ayah'] = '1';
    request.fields['anggota_id'] = '1';
    request.fields['group_id'] = '1';
    request.fields['catatan'] = '1';
    // Ganti dengan ID khotmul yang sesuai
    // Kirim request
    var response = await request.send();
    print(response.statusCode);
    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal upload data")));
    }
  }

  Widget buildPagination() {
    List<Widget> pages = [];

    for (int i = 1; i <= lastPage; i++) {
      if (i == 1 ||
          i == lastPage ||
          (i >= currentPage - 2 && i <= currentPage + 2)) {
        pages.add(
          InkWell(
            onTap: () => fetchData(page: i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: i == currentPage ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                "$i",
                style: TextStyle(
                  color: i == currentPage ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      } else if (i == currentPage - 3 || i == currentPage + 3) {
        pages.add(const Text("..."));
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: pages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Recorder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 80,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? "Stop Recording" : "Start Recording"),
            ),
            const SizedBox(height: 20),
            if (_filePath != null) ...[
              Text("Saved at: $_filePath"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _playRecording,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? "..." : "..."),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _shareRecording,
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: saveRecording,
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                  ),
                ],
              ),
            ],
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: anggota.length,
                      itemBuilder: (context, index) {
                        final item = anggota[index];
                        MaterialColor warna;
                        // ignore: unused_local_variable
                        IconData button;
                        item['status'] == ""
                            ? {warna = Colors.red, button = Icons.close}
                            : {warna = Colors.green, button = Icons.check};
                        return ListTile(
                          // leading: CircleAvatar(
                          //   backgroundColor: warna,
                          //   child: Text(
                          //     item['juz'] != null
                          //         ? item['juz'].toString()
                          //         : '-',
                          //     style: const TextStyle(color: Colors.white),
                          //   ),
                          // ),
                          title: Text(
                            "Juz ${item['juz'] ?? ''}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: anggota_id == item['anggota_id'].toString()
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Anggota ID : ${item['anggota_id'] ?? '-'}\n",
                                style: TextStyle(
                                  color: warna,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Play Rekaman ",
                                    style: TextStyle(
                                      color: warna,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(Icons.play_arrow, color: warna),
                                ],
                              ),
                            ],
                          ),

                          trailing: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.red,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const RecorderPage(),
                                //   ),
                                // );
                              } else if (value == 'delete') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Delete ${item['name']}"),
                                  ),
                                );
                              } else if (value == 'khatam') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Add Khatam ${item['name']}"),
                                  ),
                                );
                              } else if (value == 'donasi') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Add Donasi ${item['name']}"),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.record_voice_over,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Share Khotmul"),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              // const PopupMenuItem(
                              //   value: 'khatam',
                              //   child: Row(
                              //     children: [
                              //       Icon(
                              //         Icons.check_circle,
                              //         color: Colors.green,
                              //       ),
                              //       SizedBox(width: 8),
                              //       Text("Add Khatam"),
                              //     ],
                              //   ),
                              // ),
                              // const PopupMenuItem(
                              //   value: 'donasi',
                              //   child: Row(
                              //     children: [
                              //       Icon(
                              //         Icons.account_balance_wallet,
                              //         color: Colors.purple,
                              //       ),
                              //       SizedBox(width: 8),
                              //       Text("Add Donasi"),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(color: Colors.grey, height: 1),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
