/// Notifikasi user dari `GET /api/v1/notifications`.
class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type; // reminder | warning | done
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final read = json['is_read'];
    return AppNotification(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'reminder',
      isRead: read == true || read == 1 || read == '1',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
