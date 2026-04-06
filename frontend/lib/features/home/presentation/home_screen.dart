import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';
import 'package:masjid_connect/features/masjid/data/masjid_repository.dart';
import 'package:masjid_connect/features/masjid/domain/masjid_model.dart';

// ── Providers ─────────────────────────────────────────────────────────────
final prayerTimingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ref.read(masjidRepoProvider).getPrayerTimings(lat: 24.8607, lon: 67.0011);
});

final nearbyMasjidsProvider = FutureProvider<List<Masjid>>((ref) async {
  return await ref.read(masjidRepoProvider).getNearbyMasjids(lat: 24.8607, lon: 67.0011);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final prayersAsync = ref.watch(prayerTimingsProvider);
    final masjidsAsync = ref.watch(nearbyMasjidsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.obsidianGradient,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/premium_logo_final.png', height: 32),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Assalamu Alaikum 👋', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.35), fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                  Text(user?.fullName ?? 'Saathi', style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
                                ],
                              ),
                            ],
                          ),
                          _HeaderIcon(icon: Icons.notifications_none_rounded, onTap: () => context.push('/notifications'), hasBadge: true),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Real Next Prayer Card
                      prayersAsync.when(
                        data: (data) => _NextPrayerCard(timings: data),
                        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        error: (e, _) => const Center(child: Text('Ghalti: Auqat fetch nahi huye')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('Aaj ki Namaz Timings', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                prayersAsync.when(
                  data: (data) => Column(children: [
                    _PrayerTimeTile(name: 'Fajr', time: data['Fajr'] ?? '--:--', status: 'active'),
                    _PrayerTimeTile(name: 'Dhuhr', time: data['Dhuhr'] ?? '--:--', status: 'active'),
                    _PrayerTimeTile(name: 'Asr', time: data['Asr'] ?? '--:--', status: 'active'),
                    _PrayerTimeTile(name: 'Maghrib', time: data['Maghrib'] ?? '--:--', status: 'active'),
                    _PrayerTimeTile(name: 'Isha', time: data['Isha'] ?? '--:--', status: 'active'),
                  ]),
                  loading: () => const SizedBox(),
                  error: (e, _) => const SizedBox(),
                ),
                const SizedBox(height: 24),
                const Text('Nazdeeqi Masajid', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                masjidsAsync.when(
                  data: (masjids) => Column(children: masjids.map((m) => _NearbyMasjidCard(
                    name: m.name, 
                    distance: 'N/A', 
                    maslak: m.maslak ?? 'Hanafi', 
                    nextPrayer: 'Live Update'
                  )).toList()),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => const Center(child: Text('Masjids load nahi huyein')),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  final Map<String, dynamic> timings;
  const _NextPrayerCard({required this.timings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.access_time_filled_rounded, color: Color(0xFFD4AF37), size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Namaz ke Auqat', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              const Text('Dhuhr · In Progress', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Update ho rahay hain...', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFFD4AF37), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasBadge;
  const _HeaderIcon({required this.icon, required this.onTap, this.hasBadge = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08), border: Border.all(color: Colors.white.withOpacity(0.12))),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        if (hasBadge)
          Positioned(right: 12, top: 12, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFEF4444), shape: BoxShape.circle))),
      ],
    );
  }
}

class _PrayerTimeTile extends StatelessWidget {
  final String name, time, status;
  const _PrayerTimeTile({required this.name, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    final isNext = status == 'next';
    final isPast = status == 'past';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isNext ? const Color(0xFFD4AF37).withOpacity(0.08) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isNext ? const Color(0xFFD4AF37).withOpacity(0.3) : Colors.white.withOpacity(0.03)),
        boxShadow: isNext ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))] : null,
      ),
      child: Row(
        children: [
          Text(name, style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: isPast ? Colors.white.withOpacity(0.3) : Colors.white)),
          const Spacer(),
          if (isNext) Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(8)),
            child: const Text('NEXT', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
          ),
          const SizedBox(width: 12),
          Text(time, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: isPast ? Colors.white.withOpacity(0.3) : isNext ? const Color(0xFFD4AF37) : Colors.white)),
        ],
      ),
    );
  }
}

class _NearbyMasjidCard extends StatelessWidget {
  final String name, distance, maslak, nextPrayer;
  const _NearbyMasjidCard({required this.name, required this.distance, required this.maslak, required this.nextPrayer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mosque_rounded, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text('$maslak · $nextPrayer', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(distance, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37))),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white.withOpacity(0.2)),
            ],
          ),
        ],
      ),
    );
  }
}
