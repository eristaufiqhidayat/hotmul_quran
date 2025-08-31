import 'package:flutter/material.dart';
import 'package:hotmul_quran/model/surah_model.dart';
import 'package:hotmul_quran/pages/surah_detil_page.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Surah>>(
      future: QuranApi.fetchAllSurah(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final surahList = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: surahList.length,
          itemBuilder: (context, i) {
            final s = surahList[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.green, width: 1),
              ),
              color: Colors.green[50], // background hijau muda
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.green[200],
                  child: Text(
                    s.number.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  s.nameLatin,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "${s.translationId} (${s.ayahCount} ayat)",
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  s.nameArabic,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SurahDetailPage(number: s.number, name: s.nameLatin),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
