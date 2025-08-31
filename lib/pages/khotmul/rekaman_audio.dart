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
  const RecorderPage({super.key});

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final AudioRecorder _record = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;

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

  Future<void> saveRecording() async {
    final token = await getToken();
    final url = Uri.parse("${GlobalConst.url}/api/v1/khotmul/upload");

    var request = http.MultipartRequest("POST", url);

    // Tambahkan header
    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    // Tambahkan file (pastikan _filePath adalah path ke file yang valid)
    request.files.add(await http.MultipartFile.fromPath("file", _filePath!));

    // Kirim request
    var response = await request.send();

    // Baca response body
    final respStr = await response.stream.bytesToString();

    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal upload data")));
    }
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
          ],
        ),
      ),
    );
  }
}
