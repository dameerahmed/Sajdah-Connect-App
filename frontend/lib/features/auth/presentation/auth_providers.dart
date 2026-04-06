import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masjid_connect/features/auth/data/auth_repository.dart';

import 'package:masjid_connect/features/auth/domain/user_model.dart' as domain;

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepoProvider));
});

class AuthState {
  final String? token;
  final domain.User? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  AuthState copyWith({
    Object? token = _unset,
    Object? user = _unset,
    bool? isLoading,
    Object? error = _unset,
    bool? isInitialized,
  }) {
    return AuthState(
      token: identical(token, _unset) ? this.token : token as String?,
      user: identical(user, _unset) ? this.user : user as domain.User?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

const Object _unset = Object();

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(AuthState()) {
    _init();
  }

  static const String _tokenKey = 'auth_token';

  Future<void> _init() async {
    try {
      debugPrint('AUTH_INIT: Starting session initialization...');
      final hasToken = await _loadToken();
      if (hasToken) {
        debugPrint('AUTH_INIT: Token found, fetching user...');
        // Try to fetch user with a short timeout
        await fetchCurrentUser().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('AUTH_INIT: fetchCurrentUser timed out after 3s');
            return null;
          },
        );
      } else {
        debugPrint('AUTH_INIT: No token found.');
      }
    } catch (e) {
      debugPrint('AUTH_INIT: Initialization error: $e');
    } finally {
      debugPrint('AUTH_INIT: Marking initialized = true');
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<bool> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      state = state.copyWith(token: token);
    } catch (e) {
      print("Error loading token: $e");
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final userData = await _repo.getCurrentUser();
      state = state.copyWith(user: domain.User.fromJson(userData));
    } catch (e) {
      print("Fetch current user failed: $e");
      // If token is invalid or server unreachable, we don't necessarily logout 
      // immediately unless it's a 401, but for safety during init we can just proceed.
      // If it's a connection error, logout() might also hang if it tries to talk to server.
      if (e.toString().contains('401')) {
        await logout();
      }
    }
  }

  Future<void> signup(String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.signup(email, password, fullName);
      final token = res['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        state = state.copyWith(token: token, isLoading: false);
        await fetchCurrentUser();
      } else {
        state = state.copyWith(isLoading: false, error: 'Signup failed: no access token returned.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.login(email, password);
      final token = res['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        state = state.copyWith(token: token, isLoading: false);
        await fetchCurrentUser();
      } else {
        state = state.copyWith(isLoading: false, error: 'Login failed: no access token returned.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> googleLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.googleLogin();
      final token = res['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        state = state.copyWith(token: token, isLoading: false);
        await fetchCurrentUser();
      } else {
        state = state.copyWith(isLoading: false, error: 'Google login failed: no access token returned.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    state = state.copyWith(token: null, user: null, error: null);
  }
}
