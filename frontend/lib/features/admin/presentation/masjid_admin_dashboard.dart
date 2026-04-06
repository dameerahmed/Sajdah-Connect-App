import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/core/network/api_service.dart';
import 'package:masjid_connect/features/masjid/domain/masjid_model.dart';

// ── Providers ─────────────────────────────────────────────────────────────
final myMasjidProvider = FutureProvider<Masjid?>((ref) async {
  try {
    final dio = ref.read(apiServiceProvider).dio;
    final response = await dio.get('/masjid/my');
    if (response.statusCode == 200 && response.data != null) {
      return Masjid.fromJson(response.data);
    }
  } catch (e) {
    debugPrint("My Masjid fetch error: $e");
  }
  return null;
});

class MasjidAdminDashboard extends ConsumerStatefulWidget {
  const MasjidAdminDashboard({super.key});

  @override
  ConsumerState<MasjidAdminDashboard> createState() => _MasjidAdminDashboardState();
}

class _MasjidAdminDashboardState extends ConsumerState<MasjidAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final masjidAsync = ref.watch(myMasjidProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset('assets/images/premium_logo_final.png', height: 28),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white38,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Timings'), Tab(text: 'Media')],
        ),
      ),
      body: masjidAsync.when(
        data: (masjid) => masjid == null 
            ? const Center(child: Text('Masjid register karein!'))
            : TabBarView(
                controller: _tabController,
                children: [
                   _OverviewTab(masjid: masjid),
                   _TimingsTab(masjid: masjid),
                   _MediaTab(masjid: masjid),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Ghalti: $e')),
      ),
    );
  }
}

// ── Media Tab ──────────────────────────────────────────────────────────────
class _MediaTab extends ConsumerWidget {
  final Masjid masjid;
  const _MediaTab({required this.masjid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isApproved = masjid.status == MasjidStatus.active;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('MASJID REELS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1.5)),
            if (isApproved)
              TextButton.icon(
                onPressed: () => _uploadVideo(context, ref, masjid.id),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                label: const Text('New Reel', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (!isApproved)
          const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: Text('Approval ke baad reels upload karain', style: TextStyle(color: Colors.white24))))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7),
            itemCount: 4, // Placeholder for real masjid-specific reels
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: const Icon(Icons.play_circle_outline, color: Colors.white24, size: 40),
            ),
          ),
      ],
    );
  }

  void _uploadVideo(BuildContext context, WidgetRef ref, int masjidId) {
    // Logic for ImagePicker and Cloudinary upload trigger
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video selection khul rahi hai...')));
  }
}

class _OverviewTab extends StatelessWidget {
  final Masjid masjid;
  const _OverviewTab({required this.masjid});

  @override
  Widget build(BuildContext context) {
    bool isApproved = masjid.status == MasjidStatus.active;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Status Alert
        if (!isApproved)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withOpacity(0.3))),
            child: const Row(children: [Icon(Icons.hourglass_empty_rounded, color: Colors.orange), SizedBox(width: 12), Expanded(child: Text('Verification In Progress. Approval ke baad hi auqat update kar saktay hain.', style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600)))]),
          ),

        // Info Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
          child: Row(children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.mosque_outlined, color: Colors.black, size: 30)),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(masjid.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
              const SizedBox(height: 4),
              Text(masjid.address, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ])),
          ]),
        ),

        const SizedBox(height: 32),
        const Text('CONTROL PANEL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16,
          children: [
            _ActionCard(icon: Icons.campaign_rounded, title: 'Push Alert', color: Colors.orange, enabled: isApproved, onTap: () {}),
            _ActionCard(icon: Icons.insights_rounded, title: 'Stats', color: Colors.blue, enabled: isApproved, onTap: () {}),
            _ActionCard(icon: Icons.edit_location_alt_rounded, title: 'Map Settings', color: Colors.green, enabled: isApproved, onTap: () {}),
            _ActionCard(icon: Icons.share_rounded, title: 'Share Link', color: Colors.purple, enabled: isApproved, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

// ── Timings Tab ────────────────────────────────────────────────────────────
class _TimingsTab extends StatelessWidget {
  final Masjid masjid;
  const _TimingsTab({required this.masjid});

  @override
  Widget build(BuildContext context) {
    bool isApproved = masjid.status == MasjidStatus.active;

    if (!isApproved) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 20),
            const Text('Timings Locked', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Sirf Approved Masjids update kar sakti hain.', style: TextStyle(color: Colors.white.withOpacity(0.4))),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('JAMAT TIMINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _TimeEditTile(label: 'Fajr', time: masjid.fajr),
        _TimeEditTile(label: 'Dhuhr', time: masjid.dhuhr),
        _TimeEditTile(label: 'Asr', time: masjid.asr),
        _TimeEditTile(label: 'Maghrib', time: masjid.maghrib),
        _TimeEditTile(label: 'Isha', time: masjid.isha),
        _TimeEditTile(label: 'Jummah', time: masjid.jummah),
      ],
    );
  }
}

class _TimeEditTile extends ConsumerWidget {
  final String label, time;
  const _TimeEditTile({required this.label, required this.time});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: Colors.black,
                  surface: AppColors.surface,
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final formattedTime = picked.format(context);
          // Logic to update this specific timing on backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label timing $formattedTime par set ho gayi!')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.03))),
        child: Row(children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
          const Spacer(),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
          const SizedBox(width: 12),
          const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
        ]),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title; final Color color; final bool enabled; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.color, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.3,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.03))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
