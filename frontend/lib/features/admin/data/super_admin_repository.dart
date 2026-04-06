import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';
import 'package:masjid_connect/features/masjid/domain/masjid_model.dart';
import 'package:masjid_connect/core/network/api_service.dart';
import 'package:dio/dio.dart';

class AdminStats {
  final int totalUsers;
  final int activeMasjids;
  final int pendingRequests;
  final int totalReels;

  AdminStats({
    required this.totalUsers,
    required this.activeMasjids,
    required this.pendingRequests,
    required this.totalReels,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] ?? 0,
      activeMasjids: json['active_masjids'] ?? 0,
      pendingRequests: json['pending_requests'] ?? 0,
      totalReels: json['total_reels'] ?? 0,
    );
  }
}

class SuperAdminRepository {
  final Dio _dio;

  SuperAdminRepository(this._dio);

  Future<AdminStats> fetchStats() async {
    try {
      final response = await _dio.get('/super-admin/stats');
      return AdminStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch stats: $e');
    }
  }

  Future<List<Masjid>> fetchPendingMasjids() async {
    try {
      final response = await _dio.get('/super-admin/pending-masjids');
      return (response.data as List).map((m) => Masjid.fromJson(m)).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending masjids: $e');
    }
  }

  Future<List<Masjid>> fetchApprovedMasjids() async {
    try {
      final response = await _dio.get('/super-admin/approved-masjids');
      return (response.data as List).map((m) => Masjid.fromJson(m)).toList();
    } catch (e) {
      throw Exception('Failed to fetch approved masjids: $e');
    }
  }

  Future<List<Masjid>> fetchRejectedMasjids() async {
    try {
      final response = await _dio.get('/super-admin/rejected-masjids');
      return (response.data as List).map((m) => Masjid.fromJson(m)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rejected masjids: $e');
    }
  }

  Future<void> approveMasjid(int id) async {
    try {
      await _dio.post('/super-admin/approve-masjid/$id');
    } catch (e) {
      throw Exception('Approval failed: $e');
    }
  }

  Future<void> rejectMasjid(int id) async {
    try {
      await _dio.post('/super-admin/reject-masjid/$id');
    } catch (e) {
      throw Exception('Rejection failed: $e');
    }
  }
}

final superAdminRepositoryProvider = Provider<SuperAdminRepository>((ref) {
  final dio = ref.watch(apiServiceProvider).dio;
  return SuperAdminRepository(dio);
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return ref.watch(superAdminRepositoryProvider).fetchStats();
});

final pendingMasjidsProvider = FutureProvider<List<Masjid>>((ref) async {
  return ref.watch(superAdminRepositoryProvider).fetchPendingMasjids();
});

final approvedMasjidsProvider = FutureProvider<List<Masjid>>((ref) async {
  return ref.watch(superAdminRepositoryProvider).fetchApprovedMasjids();
});

final rejectedMasjidsProvider = FutureProvider<List<Masjid>>((ref) async {
  return ref.watch(superAdminRepositoryProvider).fetchRejectedMasjids();
});
