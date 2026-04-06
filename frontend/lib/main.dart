import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_connect/l10n/app_localizations.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/core/localization/locale_provider.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';
import 'package:masjid_connect/features/auth/presentation/splash_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: MasjidConnectApp()));
}

class MasjidConnectApp extends ConsumerWidget {
  const MasjidConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final location = state.matchedLocation;
        final publicPaths = <String>{'/splash', '/login'};

        if (!authState.isInitialized) {
          return location == '/splash' ? null : '/splash';
        }

        if (authState.token == null && !publicPaths.contains(location)) {
          return '/login';
        }

        if (authState.token != null && (location == '/login' || location == '/splash')) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
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
                body: Center(
                  child: Text(
                    'Invalid masjid id',
                    style: TextStyle(color: Color(0xFFD4AF37)),
                  ),
                ),
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

    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'Sajdah Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
        Locale('sd'),
        Locale('ru'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first; // Default to English
      },
    );
  }
}
