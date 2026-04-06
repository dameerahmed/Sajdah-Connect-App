import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/masjid/domain/masjid_model.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';
import 'package:masjid_connect/features/admin/data/super_admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────
// (Removed mock providers, now using real ones from super_admin_repository.dart)

class SuperAdminDashboard extends ConsumerStatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  ConsumerState<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends ConsumerState<SuperAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingMasjidsProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Premium Admin Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.background, AppColors.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20), onPressed: () => Navigator.pop(context)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                      child: const Text('SUPER ADMIN', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  Text("${user?.fullName ?? 'Dameer'}'s\nCommand Center", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 24),
                  // Dashboard Stats
                  ref.watch(adminStatsProvider).when(
                    data: (stats) => Row(children: [
                      _StatBox(label: 'Pending', value: stats.pendingRequests.toString(), color: Colors.orange),
                      const SizedBox(width: 12),
                      _StatBox(label: 'Live', value: stats.activeMasjids.toString(), color: Colors.green),
                      const SizedBox(width: 12),
                      _StatBox(label: 'Users', value: stats.totalUsers.toString(), color: Colors.blue),
                    ]),
                    loading: () => const Center(child: LinearProgressIndicator(color: AppColors.primary)),
                    error: (e, _) => Text('Stats error: $e', style: const TextStyle(color: Colors.red, fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),

          // Tab Controls
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary, indicatorColor: AppColors.primary,
                tabs: const [Tab(text: 'Pending'), Tab(text: 'Approved'), Tab(text: 'Rejected')],
              ),
            ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MasjidStatusView(provider: pendingMasjidsProvider, showActions: true),
                _MasjidStatusView(provider: approvedMasjidsProvider, showActions: false),
                _MasjidStatusView(provider: rejectedMasjidsProvider, showActions: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasjidStatusView extends ConsumerWidget {
  final FutureProvider<List<Masjid>> provider;
  final bool showActions;
  const _MasjidStatusView({required this.provider, required this.showActions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masjidsAsync = ref.watch(provider);
    
    return masjidsAsync.when(
      data: (masjids) => masjids.isEmpty 
          ? const Center(child: Text('Koi masjid nahi is status mein.', style: TextStyle(color: Colors.white38)))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: masjids.length,
              itemBuilder: (context, i) => _AdminMasjidCard(masjid: masjids[i], showActions: showActions),
            ),
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
    );
  }
}

class _AdminMasjidCard extends ConsumerWidget {
  final Masjid masjid;
  final bool showActions;
  const _AdminMasjidCard({required this.masjid, required this.showActions});

  Future<void> _handleAction(WidgetRef ref, BuildContext context, bool approve) async {
    try {
      if (approve) {
        await ref.read(superAdminRepositoryProvider).approveMasjid(masjid.id);
      } else {
        await ref.read(superAdminRepositoryProvider).rejectMasjid(masjid.id);
      }
      
      // Refresh all related data
      ref.invalidate(pendingMasjidsProvider);
      ref.invalidate(approvedMasjidsProvider);
      ref.invalidate(rejectedMasjidsProvider);
      ref.invalidate(adminStatsProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? '${masjid.name} Approved! 🎉' : 'Rejected.'), 
          backgroundColor: approve ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.03))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.mosque_rounded, color: AppColors.primary)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(masjid.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
            Text(masjid.address, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4))),
          ])),
        ]),
        const SizedBox(height: 20),
        if (showActions) ...[
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => _handleAction(ref, context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('APPROVE'))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton(onPressed: () => _handleAction(ref, context, false), style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('REJECT'))),
          ]),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: (masjid.status == MasjidStatus.active ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(masjid.status.toString().toUpperCase().split('.').last, style: TextStyle(color: (masjid.status == MasjidStatus.active ? Colors.green : Colors.red), fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ],
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value; final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 0.5)),
      ]),
    ));
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  const _SliverTabBarDelegate(this._tabBar);
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: AppColors.background, child: _tabBar);
  @override bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
