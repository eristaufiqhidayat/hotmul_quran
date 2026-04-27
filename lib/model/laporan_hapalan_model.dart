class LaporanHafalan {
  final int userId;
  final String name;
  final int juz;
  final int progress;
  final String status;
  final String lastInput;

  LaporanHafalan({
    required this.userId,
    required this.name,
    required this.juz,
    required this.progress,
    required this.status,
    required this.lastInput,
  });

  factory LaporanHafalan.fromJson(Map<String, dynamic> json) {
    return LaporanHafalan(
      userId: json['user_id'],
      name: json['name'],
      juz: json['juz'],
      progress: json['progress'],
      status: json['status'],
      lastInput: json['last_input'] ?? '-',
    );
  }
}
