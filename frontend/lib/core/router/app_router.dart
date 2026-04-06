import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';

// Screens
import 'package:masjid_connect/features/auth/presentation/login_screen.dart';
import 'package:masjid_connect/features/home/presentation/home_screen.dart';
import 'package:masjid_connect/features/map/presentation/map_screen.dart';
import 'package:masjid_connect/features/reels/presentation/reels_screen.dart';
import 'package:masjid_connect/features/profile/presentation/profile_screen.dart';
import 'package:masjid_connect/features/masjid/presentation/masjid_profile_screen.dart';
import 'package:masjid_connect/features/masjid/presentation/register_masjid_screen.dart';
import 'package:masjid_connect/features/admin/presentation/super_admin_dashboard.dart';
import 'package:masjid_connect/features/admin/presentation/masjid_admin_dashboard.dart';
import 'package:masjid_connect/features/notifications/presentation/notifications_screen.dart';
import 'package:masjid_connect/shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isOnLogin = state.matchedLocation == '/login';

      if (!authState.isInitialized) {
        return null;
      }

      if (authState.token == null && !isOnLogin) {
        return '/login';
      }

      if (authState.token != null && isOnLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          GoRoute(path: '/reels', builder: (context, state) => const ReelsScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/masjid/:id',
        builder: (context, state) {
          final masjidId = int.tryParse(state.pathParameters['id'] ?? '');
          if (masjidId == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid masjid id')),
            );
          }
          return MasjidProfileScreen(masjidId: masjidId);
        },
      ),
      GoRoute(
        path: '/register-masjid',
        builder: (context, state) => const RegisterMasjidScreen(),
      ),
      GoRoute(
        path: '/super-admin',
        builder: (context, state) => const SuperAdminDashboard(),
      ),
      GoRoute(
        path: '/masjid-admin',
        builder: (context, state) => const MasjidAdminDashboard(),
      ),
    ],
  );
});
