import 'package:flutter_test/flutter_test.dart';
import 'package:hotmul_quran/core/tajweed.dart';

void main() {
  group('Tajweed.parse', () {
    test('memisahkan penanda hukum dari teks biasa', () {
      const raw = '۞ ٱللَّهُ نُورُ [h:9421[ٱ][l[ل]سَّمَ[n[ـٰ]و';
      final segs = Tajweed.parse(raw);

      expect(segs.map((s) => s.text).join(), '۞ ٱللَّهُ نُورُ ٱلسَّمَـٰو');
      expect(segs[1].rule?.code, 'h');
      expect(segs[2].rule?.code, 'l');
      expect(segs[4].rule?.code, 'n');
      expect(segs[3].rule, isNull);
    });

    test('teks tanpa penanda tetap utuh', () {
      final segs = Tajweed.parse('الحمد لله');
      expect(segs.length, 1);
      expect(segs.first.rule, isNull);
    });

    test('kode tidak dikenal tidak menghilangkan teks', () {
      final segs = Tajweed.parse('ab[z[cd]ef');
      expect(segs.map((s) => s.text).join(), 'abcdef');
      expect(segs[1].rule, isNull);
    });
  });

  group('Tajweed.stripLeadingBismillah', () {
    test('membuang basmalah bertanda tajwid di awal ayat', () {
      const raw =
          'بِسْمِ [h:1[ٱ]للَّهِ [h:2[ٱ][l[ل]رَّحْمَ[n[ـٰ]نِ [h:3[ٱ][l[ل]رَّح[p[ِي]مِ '
          '[h:4[ٱ]لٓمٓ';
      final segs = Tajweed.stripLeadingBismillah(Tajweed.parse(raw));
      expect(segs.map((s) => s.text).join(), 'ٱلٓمٓ');
      expect(segs.first.rule?.code, 'h');
    });

    test('ayat tanpa basmalah tidak diubah', () {
      final segs = Tajweed.parse('قُلْ هُوَ ٱللَّهُ أَحَدٌ');
      expect(Tajweed.stripLeadingBismillah(segs), same(segs));
    });
  });

  test('angka Arab-Indik', () {
    expect(Tajweed.arabicNumber(286), '٢٨٦');
  });
}
