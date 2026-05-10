class LaporanHafalan {
  final String name;
  final int juz;
  final int progress;
  final String status;
  final String lastInput;

  LaporanHafalan({
    required this.name,
    required this.juz,
    required this.progress,
    required this.status,
    required this.lastInput,
  });

  factory LaporanHafalan.fromJson(Map<String, dynamic> json) {
    return LaporanHafalan(
      name: json['name'] ?? '',
      juz: int.tryParse(json['juz'].toString()) ?? 0,
      progress: int.tryParse(json['progress'].toString()) ?? 0,
      status: json['status'] ?? '',
      lastInput: json['last_input'] ?? '',
    );
  }
}
