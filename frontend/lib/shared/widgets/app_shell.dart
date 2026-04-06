import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/notifications/presentation/notifications_screen.dart';
import 'package:masjid_connect/features/notifications/presentation/notifications_providers.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/reels')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', index: 0, currentIndex: currentIndex, onTap: () => context.go('/home')),
                _NavItem(icon: Icons.map_rounded, label: 'Map', index: 1, currentIndex: currentIndex, onTap: () => context.go('/map')),
                _NavItem(icon: Icons.play_circle_rounded, label: 'Reels', index: 2, currentIndex: currentIndex, onTap: () => context.go('/reels')),
                // Notification Bell with badge
                _NotificationNavItem(unreadCount: unreadCount, currentIndex: currentIndex, onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      builder: (_, ctrl) => Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
                            Expanded(child: ProviderScope(child: NotificationsScreen())),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', index: 3, currentIndex: currentIndex, onTap: () => context.go('/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationNavItem extends StatelessWidget {
  final int unreadCount;
  final int currentIndex;
  final VoidCallback onTap;

  const _NotificationNavItem({required this.unreadCount, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badges.Badge(
              showBadge: unreadCount > 0,
              badgeContent: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: AppColors.rejected,
                padding: EdgeInsets.all(4),
              ),
              child: const Icon(Icons.notifications_rounded, color: AppColors.textHint, size: 24),
            ),
            const SizedBox(height: 4),
            const Text('Alerts', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: isActive ? AppColors.primary : AppColors.textHint, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, color: isActive ? AppColors.primary : AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}
