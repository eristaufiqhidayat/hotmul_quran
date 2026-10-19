/// Menyetel User-Agent mirip browser untuk semua request HTTP aplikasi.
///
/// Hosting API memakai Imunify360 bot-protection yang memblokir User-Agent
/// bawaan Dart (`Dart/x.x (dart:io)`). Di Android/iOS/desktop semua request
/// lewat `dart:io` HttpClient (package:http, NetworkImage, dll.), jadi cukup
/// di-override sekali di sini. Di web browser sudah mengirim User-Agent
/// sendiri, jadi implementasinya kosong.
export 'http_override_stub.dart'
    if (dart.library.io) 'http_override_io.dart';
