import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/network/api_service.dart';
import 'package:masjid_connect/features/masjid/domain/masjid_model.dart';
import 'dart:io';

final masjidRepoProvider = Provider((ref) => MasjidRepository(ref));

class MasjidRepository {
  final Ref ref;
  MasjidRepository(this.ref);

  Future<void> registerMasjid({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String maslak,
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
    required String jummah,
    required List<File> documents,
  }) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final formData = FormData.fromMap({
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'maslak': maslak,
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'jummah': jummah,
        'documents': documents.map((file) => MultipartFile.fromFileSync(
          file.path,
          filename: file.path.split('/').last,
        )).toList(),
      });
      await dio.post('/masjid/register', data: formData);
    } catch (e) {
      throw Exception("Error registering masjid: $e");
    }
  }

  Future<List<Masjid>> getNearbyMasjids({required double lat, required double lon}) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.get('/masjids/nearby', queryParameters: {
        'lat': lat,
        'lon': lon,
      });
      final List data = response.data;
      return data.map((e) => Masjid.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Nearby Masjids fetch fail: $e");
    }
  }

  Future<Map<String, dynamic>> getPrayerTimings({required double lat, required double lon}) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.get('/prayers/timings', queryParameters: {
        'latitude': lat,
        'longitude': lon,
      });
      return response.data;
    } catch (e) {
      throw Exception("Prayer Timings fetch fail: $e");
    }
  }

  Future<Masjid> fetchMasjidById(int id) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.get('/masjids/$id');
      return Masjid.fromJson(response.data);
    } catch (e) {
      throw Exception("Masjid fetch fail: $e");
    }
  }
}

final masjidProvider = FutureProvider.family<Masjid, int>((ref, id) async {
  return ref.watch(masjidRepoProvider).fetchMasjidById(id);
});
