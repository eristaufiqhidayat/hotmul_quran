class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Message {
  final int id;
  final int senderId;
  final String targetType;
  final int? targetId;
  final String content;
  final String? createdAt;
  final User? sender;

  Message({
    required this.id,
    required this.senderId,
    required this.targetType,
    this.targetId,
    required this.content,
    this.createdAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      targetType: json['target_type'],
      targetId: json['target_id'],
      content: json['content'] ?? '',
      createdAt: json['created_at'],
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
    );
  }
}

class MessageUser {
  final int id;
  final int messageId;
  final int userId;
  final bool isRead;
  final String? createdAt;
  final Message message;

  MessageUser({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.isRead,
    this.createdAt,
    required this.message,
  });

  factory MessageUser.fromJson(Map<String, dynamic> json) {
    return MessageUser(
      id: json['id'],
      messageId: json['message_id'],
      userId: json['user_id'],
      isRead: json['is_read'] == 1,
      createdAt: json['created_at'],
      message: Message.fromJson(json['message']),
    );
  }
}
