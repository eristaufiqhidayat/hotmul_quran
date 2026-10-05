import 'package:flutter_test/flutter_test.dart';
import 'package:hotmul_quran/core/hafalan_rules.dart';
import 'package:hotmul_quran/model/assignment_model.dart';
import 'package:hotmul_quran/model/setoran_model.dart';

void main() {
  group('Rolling schedule (BRD 4.2)', () {
    test('anggota urutan 1 dapat juz 1, 2, 3 di periode 1, 2, 3', () {
      expect(HafalanRules.juzForPeriod(orderNumber: 1, period: 1), 1);
      expect(HafalanRules.juzForPeriod(orderNumber: 1, period: 2), 2);
      expect(HafalanRules.juzForPeriod(orderNumber: 1, period: 3), 3);
    });

    test('setelah juz 30 kembali ke juz 1', () {
      expect(HafalanRules.juzForPeriod(orderNumber: 30, period: 1), 30);
      expect(HafalanRules.juzForPeriod(orderNumber: 30, period: 2), 1);
      expect(HafalanRules.juzForPeriod(orderNumber: 1, period: 31), 1);
    });

    test('30 anggota mendapat 30 juz berbeda di setiap periode', () {
      for (var p = 1; p <= 30; p++) {
        final juz = {
          for (var o = 1; o <= 30; o++)
            HafalanRules.juzForPeriod(orderNumber: o, period: p),
        };
        expect(juz.length, 30);
      }
    });
  });

  group('Progress & warna (SRS FR-05)', () {
    test('hijau bila > 80% atau status done', () {
      expect(
        HafalanRules.level(progress: 0.85, dayOfPeriod: 12),
        ProgressLevel.onTrack,
      );
      expect(
        HafalanRules.level(progress: 0, dayOfPeriod: 3, status: 'done'),
        ProgressLevel.onTrack,
      );
    });

    test('merah bila < 50% di hari ke-10, status late, atau lewat tenggat', () {
      expect(
        HafalanRules.level(progress: 0.4, dayOfPeriod: 10),
        ProgressLevel.late,
      );
      expect(
        HafalanRules.level(progress: 0.6, dayOfPeriod: 5, status: 'late'),
        ProgressLevel.late,
      );
      expect(
        HafalanRules.level(progress: 0.6, dayOfPeriod: 14, daysRemaining: -1),
        ProgressLevel.late,
      );
    });

    test('kuning untuk kondisi di antaranya', () {
      expect(
        HafalanRules.level(progress: 0.4, dayOfPeriod: 9),
        ProgressLevel.warning,
      );
      expect(
        HafalanRules.level(progress: 0.7, dayOfPeriod: 12),
        ProgressLevel.warning,
      );
    });

    test('progress aman untuk target 0 dan dibatasi 100%', () {
      expect(HafalanRules.progress(5, 0), 0);
      expect(HafalanRules.progress(300, 200), 1);
      expect(HafalanRules.progress(50, 200), 0.25);
    });
  });

  group('Tenggat 2 pekan (BRD 4.4)', () {
    final start = DateTime(2026, 10, 1);
    final end = DateTime(2026, 10, 14);

    test('hari ke- dan sisa hari', () {
      expect(HafalanRules.dayOfPeriod(start, DateTime(2026, 10, 1, 23)), 1);
      expect(HafalanRules.dayOfPeriod(start, DateTime(2026, 10, 14)), 14);
      expect(HafalanRules.daysRemaining(end, DateTime(2026, 10, 11)), 3);
      expect(HafalanRules.daysRemaining(end, DateTime(2026, 10, 15)), -1);
    });

    test('pengingat H-3 dan H-1', () {
      expect(HafalanRules.deadlineReminder(3, juz: 5), contains('3 hari'));
      expect(HafalanRules.deadlineReminder(1, juz: 5), contains('besok'));
      expect(HafalanRules.deadlineReminder(2), isNull);
      expect(HafalanRules.deadlineReminder(7), isNull);
    });

    test('tidak aktif setelah 14 hari tanpa laporan (FR-06)', () {
      final today = DateTime(2026, 10, 20);
      expect(HafalanRules.isInactive(DateTime(2026, 10, 6), today), isTrue);
      expect(HafalanRules.isInactive(DateTime(2026, 10, 7), today), isFalse);
      expect(HafalanRules.isInactive(null, today), isTrue);
    });
  });

  group('Validasi setoran ayat', () {
    test('menolak input tidak valid', () {
      expect(HafalanRules.validateAyatRange(null, 5), isNotNull);
      expect(HafalanRules.validateAyatRange(0, 5), isNotNull);
      expect(HafalanRules.validateAyatRange(10, 5), isNotNull);
      expect(HafalanRules.validateAyatRange(1, 250, maxAyat: 200), isNotNull);
    });

    test('menerima rentang valid', () {
      expect(HafalanRules.validateAyatRange(1, 200, maxAyat: 200), isNull);
      expect(HafalanRules.validateAyatRange(3, 5), isNull);
    });
  });

  group('Parsing respon API', () {
    test('assignment-active', () {
      final a = Assignment.fromJson({
        'assignment_id': 12,
        'juz': '7',
        'start_date': '2026-10-01',
        'end_date': '2026-10-14',
      });
      expect(a.id, 12);
      expect(a.juzNumber, 7);
      expect(a.daysRemaining(DateTime(2026, 10, 13)), 1);
    });

    test('hafalan/today', () {
      final g = SetoranGroup.fromJson({
        'group_id': 1,
        'group_name': 'Grup A',
        'periode': 3,
        'data': [
          {
            'id': 9,
            'name': 'Ali',
            'juz': 3,
            'status_assignment': 'active',
            'sudah_setor': true,
            'ayat_from': 1,
            'ayat_to': 20,
            'total_ayat': 20,
            'target_ayat': 148,
          },
        ],
      });
      expect(g.groupName, 'Grup A');
      expect(g.byUser(9)?.sudahSetor, isTrue);
      expect(g.byUser(9)?.bisaSetor, isTrue);
      expect(g.byUser(1), isNull);
    });
  });
}
