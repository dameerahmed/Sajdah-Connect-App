import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/masjid/domain/masjid_model.dart';
import 'package:masjid_connect/features/home/presentation/home_screen.dart'; // For nearbyMasjidsProvider

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Masjid? _selectedMasjid;
  final MapController _mapController = MapController();
  // Default: Karachi
  final LatLng _userLocation = const LatLng(24.8607, 67.0011);

  @override
  Widget build(BuildContext context) {
    final masjidsAsync = ref.watch(nearbyMasjidsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 14,
              onTap: (_, __) => setState(() => _selectedMasjid = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.masjidconnect.app',
              ),
              masjidsAsync.when(
                data: (masjids) => MarkerLayer(
                  markers: [
                    // User Location Marker
                    Marker(
                      point: _userLocation,
                      width: 50, height: 50,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, spreadRadius: 3)]),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                    // Real Masjid Markers
                    ...masjids.map((m) => Marker(
                      point: LatLng(m.latitude, m.longitude),
                      width: 56, height: 56,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedMasjid = m);
                          _mapController.move(LatLng(m.latitude, m.longitude), 15);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]),
                          child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 26),
                        ),
                      ),
                    )),
                  ],
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (e, _) => const MarkerLayer(markers: []),
              ),
            ],
          ),

          // Top Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Masjid ya maslak dhoondein...',
                    border: InputBorder.none,
                    filled: false,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // Masjid Bottom Sheet Preview
          if (_selectedMasjid != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _MasjidPreviewSheet(
                masjid: _selectedMasjid!,
                onClose: () => setState(() => _selectedMasjid = null),
                onViewProfile: () => context.push('/masjid/${_selectedMasjid!.id}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _MasjidPreviewSheet extends StatelessWidget {
  final Masjid masjid;
  final VoidCallback onClose;
  final VoidCallback onViewProfile;

  const _MasjidPreviewSheet({required this.masjid, required this.onClose, required this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 50.0, end: 0.0),
      curve: Curves.easeOutCubic,
      builder: (context, offset, child) => Transform.translate(offset: Offset(0, offset), child: child),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 30, offset: const Offset(0, -8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(masjid.name, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
                            child: Text(masjid.maslak ?? 'Hanafi', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                          Expanded(child: Text(masjid.address, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                        ]),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(Icons.close_rounded, color: Colors.grey[400], size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Jam'at Times Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TimeChip(name: 'Fajr', time: masjid.fajr),
                  _TimeChip(name: 'Dhuhr', time: masjid.dhuhr),
                  _TimeChip(name: 'Asr', time: masjid.asr),
                  _TimeChip(name: 'Maghrib', time: masjid.maghrib),
                  _TimeChip(name: 'Isha', time: masjid.isha),
                ],
              ),
              const SizedBox(height: 16),

              // View Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onViewProfile,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Full Profile Dekhein'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String name;
  final String time;
  const _TimeChip({required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}
