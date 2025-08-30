import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/surah_model.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahId;
  const SurahDetailPage({
    super.key,
    required this.surahId, // opsional dengan default value
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<Surah> futureSurah;

  @override
  void initState() {
    super.initState();
    futureSurah = QuranApi.fetchSurah(widget.surahId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Surah ${widget.surahId}")),
      body: FutureBuilder<Surah>(
        future: futureSurah,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final surah = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "${surah.nameLatin} (${surah.nameArabic})",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "${surah.translationId} • ${surah.ayahCount} ayat",
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Divider(),
              ...surah.verses!.map(
                (ayah) => ListTile(
                  leading: CircleAvatar(child: Text("${ayah.inSurahNumber}")),
                  title: Text(
                    ayah.arabic,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 20, fontFamily: "Amiri"),
                  ),
                  subtitle: Text(ayah.translationId),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
