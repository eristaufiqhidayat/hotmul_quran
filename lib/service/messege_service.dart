import 'dart:convert';
import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/service/token_services.dart';
import 'package:http/http.dart' as http;
import 'package:hotmul_quran/model/messege_model.dart';

class MessageService {
  final String baseUrl = "${GlobalConst.url}/api/v1";

  Future<bool> sendMessage({
    required int senderId,
    required String targetType,
    int? targetId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/messages/send"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender_id": senderId,
        "target_type": targetType,
        "target_id": targetId,
        "content": content,
      }),
    );

    return response.statusCode == 200;
  }

  Future<List<MessageUser>> getInbox(int userId) async {
    final token = await getValidAccessToken();
    final response = await http.get(
      Uri.parse("$baseUrl/messages/inbox/${userId}"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MessageUser.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load inbox service");
    }
  }

  Future<int> getcountUnread(int userId) async {
    final token = await getValidAccessToken();
    final response = await http.get(
      Uri.parse("$baseUrl/messages/countUnread/${userId}"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );
    print("User ID ${userId}");
    print(response.body);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      final count = result['unread_count'];
      if (count == null) {
        return 0; // default kalau tidak ada field count
      }
      return count as int;
    } else {
      throw Exception("Failed to load unread count");
    }
  }
}
