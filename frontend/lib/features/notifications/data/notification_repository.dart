import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/network/api_service.dart';

final notificationRepoProvider = Provider((ref) => NotificationRepository(ref));

class NotificationRepository {
  final Ref ref;
  NotificationRepository(this.ref);

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      // In professional apps, we also send the current locale in headers
      final response = await dio.get('/notifications');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print("Notification fetch error: $e");
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.get('/notifications/unread-count');
      return response.data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
