import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/reels/data/reel_repository.dart';
import 'package:shimmer/shimmer.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final int reelId;
  const CommentsBottomSheet({super.key, required this.reelId});

  @override
  ConsumerState<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _comments = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
        _fetchNextPage();
      }
    });
  }

  Future<void> _fetchNextPage() async {
    setState(() => _isLoading = true);
    final newComments = await ref.read(reelRepoProvider).fetchComments(widget.reelId, page: _currentPage);
    setState(() {
      _isLoading = false;
      if (newComments.isEmpty) {
        _hasMore = false;
      } else {
        _comments.addAll(newComments);
        _currentPage++;
      }
    });
  }

  void _postComment() {
    if (_commentController.text.isEmpty) return;
    
    final text = _commentController.text;
    _commentController.clear();

    // ⚡ Optimistic UI: Add locally first
    setState(() {
      _comments.insert(0, {
        'user': {'full_name': 'Aap (You)', 'profile_pic': null},
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    FocusScope.of(context).unfocus();
    // API Call in background
    // ref.read(reelRepoProvider).postComment(widget.reelId, text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.all(12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
          const Text('Comments', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16)),
          const Divider(color: Colors.white10, height: 24),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _comments.length + (_isLoading ? 3 : 0),
              itemBuilder: (context, index) {
                if (index >= _comments.length) return _buildShimmerLoading();
                final comment = _comments[index];
                return _CommentTile(comment: comment);
              },
            ),
          ),

          // ✍️ Comment Input
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      fillColor: Colors.white.withOpacity(0.05),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(onPressed: _postComment, icon: const Icon(Icons.send_rounded, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          const CircleAvatar(radius: 18),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 100, height: 10, color: Colors.white),
            const SizedBox(height: 6),
            Container(width: 200, height: 10, color: Colors.white),
          ]),
        ]),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 18, backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white38, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment['user']?['full_name'] ?? 'User', style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(comment['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.favorite_border, color: Colors.white24, size: 16),
        ],
      ),
    );
  }
}
