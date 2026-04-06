import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:masjid_connect/core/network/api_service.dart';
import 'package:masjid_connect/core/config/api_config.dart';

final authRepoProvider = Provider((ref) => AuthRepository(ref));

class AuthRepository {
  final Ref ref;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: ApiConfig.googleClientId,
  );

  AuthRepository(this.ref);

  Future<Map<String, dynamic>> signup(String email, String password, String fullName) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      });
      return response.data;
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<Map<String, dynamic>> googleLogin() async {
    try {
      // Reset any stale session before opening account picker.
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception("Google Sign-In cancelled");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          "Google idToken is null. Check GOOGLE_WEB_CLIENT_ID and ensure Android package/SHA are configured in Google Cloud Console.",
        );
      }

      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.post('/auth/google-login', data: {
        'id_token': idToken,
      });
      return response.data;
    } on DioException catch (e) {
      print('Google login DioException type: ${e.type}');
      print('Google login DioException status: ${e.response?.statusCode}');
      print('Google login DioException body: ${e.response?.data}');
      final serverMessage = e.response?.data?.toString();
      throw Exception("Google Login API failed: ${serverMessage ?? e.message}");
    } catch (e, st) {
      print('Google login error: $e');
      print('Google login stack: $st');
      final message = e.toString();
      if (message.contains('ApiException: 10') || message.contains('DEVELOPER_ERROR')) {
        throw Exception(
          "Google configuration error (DEVELOPER_ERROR). Register package com.example.frontend with SHA-1/SHA-256 and verify GOOGLE_WEB_CLIENT_ID.",
        );
      }
      throw Exception("Google Login failed: $e");
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final dio = ref.read(apiServiceProvider).dio;
      final response = await dio.get('/auth/me');
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch user profile: $e");
    }
  }
}
