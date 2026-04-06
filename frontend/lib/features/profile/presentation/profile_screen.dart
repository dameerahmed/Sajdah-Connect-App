import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_connect/l10n/app_localizations.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/core/localization/locale_provider.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';
import 'package:masjid_connect/features/auth/domain/user_model.dart' as domain;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    final isSuperAdmin = user?.role == domain.UserRole.super_admin;
    final isMasjidAdmin = user?.role == domain.UserRole.masjid_admin;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(gradient: AppColors.obsidianGradient),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/premium_logo_final.png', height: 40),
                            IconButton(
                              icon: const Icon(Icons.settings_rounded, color: AppColors.primary, size: 28),
                              onPressed: () => _showSettingsSheet(context, l10n),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 3),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 40)],
                          ),
                          child: CircleAvatar(
                            backgroundColor: AppColors.surfaceVariant,
                            backgroundImage: user?.profilePic != null ? NetworkImage(user!.profilePic!) : null,
                            child: user?.profilePic == null ? const Icon(Icons.person_rounded, size: 50, color: Colors.white) : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(user?.fullName ?? 'Saathi', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('@${user?.email.split('@')[0] ?? 'pyaara_saathi'}', style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1),
                  tabs: [
                    Tab(text: l10n.settings.toUpperCase()),
                    const Tab(text: 'SAVED REELS'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (isSuperAdmin) ...[
                    const _SectionHeader(title: 'Command Center'),
                    _SuperAdminCard(onTap: () => context.push('/super-admin')),
                  ],
                  if (isMasjidAdmin) ...[
                    const _SectionHeader(title: 'Management'),
                    _MasjidAdminCard(onTap: () => context.push('/masjid-admin')),
                  ],
                  _SectionHeader(title: l10n.language),
                  const _LanguageSelector(),
                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Community'),
                  _ProfileMenuCard(
                    icon: Icons.add_business_rounded, title: l10n.registerMasjid,
                    subtitle: 'Nai masjid add karein - Super Admin approve karega',
                    color: AppColors.primary, onTap: () => context.push('/register-masjid'),
                  ),
                  const SizedBox(height: 24),
                  _ProfileMenuItem(icon: Icons.logout_rounded, title: 'Sign Out', isDestructive: true, onTap: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  }),
                ],
              ),
              const _SavedReelsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            const _ProfileMenuItem(icon: Icons.person_outline_rounded, title: 'Edit Profile', onTap: null),
            const _ProfileMenuItem(icon: Icons.notifications_none_rounded, title: 'Notifications', onTap: null),
            const _ProfileMenuItem(icon: Icons.security_rounded, title: 'Privacy Policy', onTap: null),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Helper: Sticky TabBar Delegate ──────────────────────────────────────────
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

// ── Helper: Saved Reels Grid ────────────────────────────────────────────────
class _SavedReelsGrid extends StatelessWidget {
  const _SavedReelsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 9 / 16,
      ),
      itemCount: 0, 
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    
    final languages = [
      {'name': 'English', 'code': 'en', 'label': 'EN'},
      {'name': 'اردو', 'code': 'ur', 'label': 'UR'},
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final lang = languages[index];
          final active = currentLocale.languageCode == lang['code'];

          return InkWell(
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(Locale(lang['code']!));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFD4AF37) : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: active ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.05)),
                boxShadow: active ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))] : null,
              ),
              alignment: Alignment.center,
              child: Text(
                lang['name']!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: active ? Colors.black : Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SuperAdminCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SuperAdminCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFF3E5AB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.black, size: 30),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SUPER ADMIN PORTAL', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
                  Text('Review masjid registrations', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MasjidAdminCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MasjidAdminCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFFD4AF37), size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MASJID DASHBOARD', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('Update timings & live clips', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileMenuCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.add_business_rounded, color: Color(0xFFD4AF37), size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.4))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 14),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37), letterSpacing: 1.5)),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ProfileMenuItem({required this.icon, required this.title, this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFEF4444) : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: (isDestructive ? const Color(0xFFEF4444) : Colors.white).withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: isDestructive ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: color))),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withOpacity(0.08)),
          ],
        ),
      ),
    );
  }
}
