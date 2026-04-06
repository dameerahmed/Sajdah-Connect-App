import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/reels/data/reel_repository.dart';
import 'package:masjid_connect/features/reels/presentation/comments_bottom_sheet.dart';
import 'package:video_player/video_player.dart';
import 'package:lottie/lottie.dart';

// ── States ────────────────────────────────────────────────────────────────
enum ReelFilter { all, following, maslak }
final reelFilterProvider = StateProvider<ReelFilter>((ref) => ReelFilter.all);

final reelsListProvider = FutureProvider.family<List<Map<String, dynamic>>, ReelFilter>((ref, filter) async {
  final filterStr = filter == ReelFilter.following ? 'FOLLOWING' : (filter == ReelFilter.maslak ? 'MASLAK' : 'ALL');
  // For Maslak, we might need the user's preferred maslak from AuthProvider
  return ref.read(reelRepoProvider).fetchReels(filter: filterStr);
});

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});
  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(reelFilterProvider);
    final reelsAsync = ref.watch(reelsListProvider(filter));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📺 Video PageView
          reelsAsync.when(
            data: (reels) => PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: reels.length,
              itemBuilder: (context, index) => _ReelItem(reel: reels[index]),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => const Center(child: Text('Videos load nahi ho sakein', style: TextStyle(color: Colors.white24))),
          ),

          // 🏷️ Top Filter Tabs (TikTok Style)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FilterTab(label: 'Following', active: filter == ReelFilter.following, onTap: () => ref.read(reelFilterProvider.notifier).state = ReelFilter.following),
                    const SizedBox(width: 20),
                    _FilterTab(label: 'For You', active: filter == ReelFilter.all, onTap: () => ref.read(reelFilterProvider.notifier).state = ReelFilter.all),
                    const SizedBox(width: 20),
                    _FilterTab(label: 'Maslak', active: filter == ReelFilter.maslak, onTap: () => ref.read(reelFilterProvider.notifier).state = ReelFilter.maslak),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _FilterTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: active ? FontWeight.w900 : FontWeight.w600, color: active ? Colors.white : Colors.white60)),
          if (active) Container(margin: const EdgeInsets.only(top: 4), width: 24, height: 2, color: Colors.white),
        ],
      ),
    );
  }
}

class _ReelItem extends ConsumerStatefulWidget {
  final Map<String, dynamic> reel;
  const _ReelItem({required this.reel});
  @override
  ConsumerState<_ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends ConsumerState<_ReelItem> {
  late VideoPlayerController _controller;
  bool _isLiked = false;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel['video_url'] ?? ''))
      ..initialize().then((_) => setState(() => _controller.play()))
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() { _isLiked = true; _showHeart = true; });
    ref.read(reelRepoProvider).toggleLike(widget.reel['id']);
    Future.delayed(const Duration(milliseconds: 1000), () => setState(() => _showHeart = false));
  }

  @override
  Widget build(BuildContext context) {
    final String masjidName = widget.reel['masjid']?['name'] ?? 'Masjid';

    return GestureDetector(
      onTap: () => _controller.value.isPlaying ? _controller.pause() : _controller.play(),
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 📺 Video Player
          if (_controller.value.isInitialized)
            VideoPlayer(_controller)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white12)),

          // ❤️ Heart Animation Overlay
          if (_showHeart)
            Center(child: Lottie.asset('assets/lottie/heart_pop.json', width: 200, repeat: false)),

          // ℹ️ Info Overlap (Bottom Left)
          Positioned(
            bottom: 30, left: 16, right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@$masjidName', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                const SizedBox(height: 8),
                Text(widget.reel['title'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              ],
            ),
          ),

          // ⚡ Action Sidebar (Right)
          Positioned(
            right: 12, bottom: 40,
            child: Column(
              children: [
                // Masjid Avatar
                _ActionButton(
                  child: Container(
                    padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(radius: 20, backgroundColor: AppColors.background, child: Icon(Icons.mosque, color: AppColors.primary)),
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  icon: Icons.favorite_rounded, color: _isLiked ? Colors.red : Colors.white, label: 'Like',
                  onTap: () => setState(() => _isLiked = !_isLiked),
                ),
                const SizedBox(height: 18),
                _ActionButton(icon: Icons.comment_rounded, label: '1.2K', onTap: () => _showComments(context)),
                const SizedBox(height: 18),
                _ActionButton(icon: Icons.bookmark_rounded, label: 'Save', onTap: () => ref.read(reelRepoProvider).toggleSave(widget.reel['id'])),
                const SizedBox(height: 18),
                const _ActionButton(icon: Icons.share_rounded, label: 'Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(reelId: widget.reel['id'] as int),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon; final String? label; final Widget? child; final Color color; final VoidCallback? onTap;
  const _ActionButton({this.icon, this.label, this.child, this.color = Colors.white, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          child ?? Icon(icon, color: color, size: 32, shadows: const [Shadow(blurRadius: 15, color: Colors.black)]),
          if (label != null) const SizedBox(height: 4),
          if (label != null) Text(label!, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
        ],
      ),
    );
  }
}
