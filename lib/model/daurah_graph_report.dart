// models/daurah_data.dart
class DaurahData {
  final String id;
  final String title;
  final int participants;
  final DateTime startDate;
  final DateTime endDate;
  final String location;

  DaurahData({
    required this.id,
    required this.title,
    required this.participants,
    required this.startDate,
    required this.endDate,
    required this.location,
  });

  factory DaurahData.fromJson(Map<String, dynamic> json) {
    return DaurahData(
      id: json['group_id'].toString() ?? '',
      title: json['group_name'] ?? 'No Title',
      participants: json['jumlah_anggota'] ?? 0,
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toString(),
      ),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toString()),
      location: json['jumlah_periode'].toString() ?? 'Unknown Location',
    );
  }
}
