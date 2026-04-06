import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_connect/l10n/app_localizations.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/notifications/data/notification_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────
final notificationsListProvider = FutureProvider((ref) async {
  return ref.read(notificationRepoProvider).fetchNotifications();
});

// ── Notification Screen ────────────────────────────────────────────────────
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Image.asset('assets/images/premium_logo_final.png', height: 28),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.refresh(notificationsListProvider),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) => notifications.isEmpty
            ? const _EmptyNotifications()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  // Using a simple substring for now, or you could use timeago package
                  final createdAt = item['created_at'] != null 
                    ? item['created_at'].toString().split('T')[0] 
                    : 'Recent';

                  return _NotificationTile(
                    title: item['title'] ?? 'Alert',
                    body: item['body'] ?? '',
                    isRead: item['is_read'] ?? true,
                    time: createdAt,
                    onTap: () {
                      if (item['deep_link'] != null) {
                        context.push(item['deep_link']);
                      }
                    },
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white24))),
      ),
    );
  }
}

// ── Notification Tile ──────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final String title, body, time;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationTile({required this.title, required this.body, required this.time, required this.isRead, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surface : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isRead ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            if (!isRead) BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Icon (Gold)
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isRead) BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20, spreadRadius: 1)
                ],
              ),
              child: const Icon(Icons.notifications_active_rounded, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800, color: !isRead ? AppColors.primary : Colors.white)),
                      Text(time, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(body, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.6), height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.03))),
            child: const Icon(Icons.notifications_off_rounded, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text('Sab Theek Hai!', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Koi naya alert nahi hai abhi.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withOpacity(0.4))),
        ],
      ),
    );
  }
}
