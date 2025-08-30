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
          print(snapshot.error);
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final surahList = snapshot.data!;
        return ListView.builder(
          itemCount: surahList.length,
          itemBuilder: (context, i) {
            final s = surahList[i];
            return ListTile(
              title: Text("${s.number}. ${s.nameLatin}"),
              subtitle: Text("${s.translationId} (${s.ayahCount} ayat)"),
              trailing: Text(
                s.nameArabic,
                style: const TextStyle(fontSize: 20),
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
            );
          },
        );
      },
    );
  }
}
