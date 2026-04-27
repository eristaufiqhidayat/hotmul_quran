import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/api_client.dart';
import 'package:hotmul_quran/model/messege_model.dart';

class MessageService {
  final String baseUrl = "${GlobalConst.url}/api/v1";

  /// SEND MESSAGE
  Future<bool> sendMessage({
    required int senderId,
    required String targetType,
    int? targetId,
    required String content,
  }) async {
    final response = await ApiClient.post(
      "$baseUrl/messages/send",
      body: {
        "sender_id": senderId,
        "target_type": targetType,
        "target_id": targetId,
        "content": content,
      },
    );

    print(response.body);

    return response.statusCode == 200;
  }

  /// INBOX
  Future<List<MessageUser>> getInbox(int userId) async {
    final response = await ApiClient.get("$baseUrl/messages/inbox/$userId");

    if (response.statusCode == 200) {
      final List<dynamic> data = ApiClient.decode(response);
      return data.map((json) => MessageUser.fromJson(json)).toList();
    }

    throw Exception("Failed to load inbox service");
  }

  /// UPDATE STATUS
  Future<void> updateStatus(int id) async {
    final response = await ApiClient.get(
      "$baseUrl/messages/updateStatus?id=$id",
    );

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception("Failed to update message status");
    }
  }

  /// COUNT UNREAD
  Future<int> getcountUnread(int userId) async {
    final response = await ApiClient.get(
      "$baseUrl/messages/countUnread/$userId",
    );

    if (response.statusCode == 200) {
      final result = ApiClient.decode(response);

      final count = result['unread_count'];
      return (count ?? 0) as int;
    }

    throw Exception("Failed to load unread count");
  }
}
