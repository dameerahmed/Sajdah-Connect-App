import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/masjid/data/masjid_repository.dart';
import 'package:masjid_connect/features/masjid/domain/masjid_model.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';

class MasjidProfileScreen extends ConsumerWidget {
  final int masjidId;
  const MasjidProfileScreen({super.key, required this.masjidId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masjidAsync = ref.watch(masjidProvider(masjidId));
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: masjidAsync.when(
        data: (masjid) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFF050505),
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(masjid.name, 
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                  overflow: TextOverflow.ellipsis,
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F0F0F), Color(0xFF2A2A2A), Color(0xFF050505)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.05), shape: BoxShape.circle),
                      child: const Icon(Icons.mosque_rounded, size: 84, color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Maslak & Info (Premium Obsidian Gold)
                  Row(children: [
                    if (masjid.maslak != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                        child: Text(masjid.maslak!, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37), letterSpacing: 0.5)),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(masjid.address, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                  ]),
                  
                  // 🔥 Admin Toggle Visibility Constraint (Dameer's Request)
                  if (masjid.status == MasjidStatus.active) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ADMIN MODE', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                              Text('Manage timings & reels', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                          Switch(
                            value: false, // Local state should handle this
                            onChanged: (val) {},
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  const Text('JAM\'AT TIMINGS', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37), letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  _TimingsGrid(masjid: masjid),
                  const SizedBox(height: 40),
                  const Text('REELS & CLIPS', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37), letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.03))),
                    child: Column(
                      children: [
                        const Icon(Icons.video_collection_outlined, size: 48, color: Colors.white12),
                        const SizedBox(height: 12),
                        Text('Koi clip upload nahi ki gayi', style: TextStyle(fontFamily: 'Inter', color: Colors.white.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _TimingsGrid extends StatelessWidget {
  final Masjid masjid;
  const _TimingsGrid({required this.masjid});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> timings = [
      {'name': 'Fajr', 'time': masjid.fajr},
      {'name': 'Dhuhr', 'time': masjid.dhuhr},
      {'name': 'Asr', 'time': masjid.asr},
      {'name': 'Maghrib', 'time': masjid.maghrib},
      {'name': 'Isha', 'time': masjid.isha},
      {'name': 'Jummah', 'time': masjid.jummah},
    ];

    return GridView.count(
      crossAxisCount: 3, 
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, 
      mainAxisSpacing: 12, 
      childAspectRatio: 1.3,
      children: timings.map((t) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212), 
          borderRadius: BorderRadius.circular(18), 
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t['name']!.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(t['time']!.isEmpty ? '--:--' : t['time']!, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      )).toList(),
    );
  }
}
