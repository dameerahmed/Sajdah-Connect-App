import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/core/config/api_config.dart';
import 'package:masjid_connect/features/auth/presentation/auth_providers.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final token = ref.watch(authProvider).token;
  return ApiService(token);
});

class ApiService {
  final String? _token;
  late final Dio dio;

  ApiService(this._token) {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    if (_token != null) {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $_token';
          return handler.next(options);
        },
      ));
    }
  }
}
