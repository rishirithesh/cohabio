import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:cohabio/core/network/api_client.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? role;
  final String? userId;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.role,
    this.userId,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? role,
    String? userId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      role: role ?? this.role,
      userId: userId ?? this.userId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState()) {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    state = state.copyWith(isLoading: true);
    final accessToken = await _storage.read(key: "access_token");
    final role = await _storage.read(key: "user_role");
    final userId = await _storage.read(key: "user_id");
    
    if (accessToken != null && role != null && userId != null) {
      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        role: role,
        userId: userId,
      );
    } else {
      state = AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiClient.post("/auth/login", data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        final accessToken = response.data["access_token"];
        final refreshToken = response.data["refresh_token"];
        final userId = response.data["user_id"];
        final role = response.data["role"];

        await _storage.write(key: "access_token", value: accessToken);
        await _storage.write(key: "refresh_token", value: refreshToken);
        await _storage.write(key: "user_id", value: userId);
        await _storage.write(key: "user_role", value: role);

        state = AuthState(
          isAuthenticated: true,
          isLoading: false,
          role: role,
          userId: userId,
        );
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data["detail"] ?? "Invalid email or password";
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "An error occurred");
    }
    return false;
  }

  Future<bool> signup(String email, String password, String phone, String role) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiClient.post("/auth/signup", data: {
        "email": email,
        "password": password,
        "phone": phone.isEmpty ? null : phone,
        "role": role,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data["detail"] ?? "Signup failed. Email may be already taken.";
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "An error occurred");
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: "access_token");
    await _storage.delete(key: "refresh_token");
    await _storage.delete(key: "user_id");
    await _storage.delete(key: "user_role");
    state = AuthState(isAuthenticated: false);
  }

  /// Google Sign-In: sends Google profile data to backend /auth/google
  /// which creates or retrieves the user account and returns JWT tokens.
  Future<bool> loginWithGoogle({
    required String email,
    String? name,
    String? picture,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await apiClient.post("/auth/google", data: {
        "email": email,
        "name": name ?? email.split("@")[0],
        "picture": picture,
      });

      if (response.statusCode == 200) {
        final accessToken = response.data["access_token"];
        final refreshToken = response.data["refresh_token"];
        final userId = response.data["user_id"];
        final role = response.data["role"];

        await _storage.write(key: "access_token", value: accessToken);
        await _storage.write(key: "refresh_token", value: refreshToken);
        await _storage.write(key: "user_id", value: userId);
        await _storage.write(key: "user_role", value: role);

        state = AuthState(
          isAuthenticated: true,
          isLoading: false,
          role: role,
          userId: userId,
        );
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data["detail"] ?? "Google sign-in failed";
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Google sign-in error");
    }
    return false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
