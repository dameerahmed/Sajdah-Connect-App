import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/network/api_service.dart';

final reelRepoProvider = Provider((ref) => ReelRepository(ref));

class ReelRepository {
  final Ref ref;
  ReelRepository(this.ref);

  Future<List<Map<String, dynamic>>> fetchReels({String filter = 'ALL', String? maslak}) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.get('/reels/', queryParameters: {
        'filter': filter,
        if (maslak != null) 'maslak': maslak,
      });
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> toggleLike(int reelId) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.post('/interactions/like/$reelId');
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> toggleSave(int reelId) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.post('/interactions/save/$reelId');
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<List<Map<String, dynamic>>> fetchComments(int reelId, {int page = 1}) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.get('/interactions/comments/$reelId', queryParameters: {'page': page});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) { return []; }
  }

  Future<Map<String, dynamic>?> postComment(int reelId, String text) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.post('/interactions/comment/$reelId', data: {'text': text});
      return Map<String, dynamic>.from(response.data);
    } catch (e) { return null; }
  }
}
