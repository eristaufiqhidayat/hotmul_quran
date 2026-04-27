class Assignment {
  final int id;
  final int juzNumber;
  final String startDate;
  final String endDate;

  Assignment({
    required this.id,
    required this.juzNumber,
    required this.startDate,
    required this.endDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      juzNumber: json['juz_number'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}
