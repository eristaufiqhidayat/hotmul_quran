import 'package:hotmul_quran/core/hafalan_rules.dart';

int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

/// Assignment juz aktif milik user login (`GET /api/v1/assignment-active`).
class Assignment {
  final int id;
  final int juzNumber;
  final DateTime? startDate;
  final DateTime? endDate;

  Assignment({
    required this.id,
    required this.juzNumber,
    this.startDate,
    this.endDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: _toInt(json['assignment_id'] ?? json['id']),
      juzNumber: _toInt(json['juz'] ?? json['juz_number']),
      startDate: _toDate(json['start_date']),
      endDate: _toDate(json['end_date']),
    );
  }

  int dayOfPeriod(DateTime today) =>
      startDate == null ? 1 : HafalanRules.dayOfPeriod(startDate!, today);

  int? daysRemaining(DateTime today) =>
      endDate == null ? null : HafalanRules.daysRemaining(endDate!, today);
}
