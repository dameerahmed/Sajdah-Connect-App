import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/features/notifications/presentation/notifications_screen.dart';

final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsListProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !(n['is_read'] ?? true)).length,
    orElse: () => 0,
  );
});
