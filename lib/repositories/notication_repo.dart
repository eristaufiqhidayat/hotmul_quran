import 'package:hotmul_quran/const/global_const.dart';
import 'package:hotmul_quran/model/notification_model.dart';
import 'package:hotmul_quran/service/api_client.dart';

class NotificationRepo {
  static const String baseUrl = GlobalConst.apiV1;

  /// `GET /notifications` (dibuat harian oleh NotificationService di API).
  Future<List<AppNotification>> getAll() async {
    final response = await ApiClient.get("$baseUrl/notifications");
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    final body = ApiClient.decode(response);
    final list = body is List ? body : (body is Map ? body['data'] : null);
    return ((list as List?) ?? const [])
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
