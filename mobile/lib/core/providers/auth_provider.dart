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
  final String? pendingVerificationEmail;
  final String? successMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.role,
    this.userId,
    this.pendingVerificationEmail,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? role,
    String? userId,
    String? pendingVerificationEmail,
    String? successMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      pendingVerificationEmail: pendingVerificationEmail ?? this.pendingVerificationEmail,
      successMessage: successMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState()) {
    tryAutoLogin();
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  void setPendingEmail(String email) {
    state = state.copyWith(pendingVerificationEmail: email);
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
    state = state.copyWith(isLoading: true, errorMessage: null);
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
      state = state.copyWith(isLoading: false, errorMessage: "An error occurred during login");
    }
    return false;
  }

  Future<bool> signup(String email, String password, String phone, String role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiClient.post("/auth/signup", data: {
        "email": email,
        "password": password,
        "phone": phone.isEmpty ? null : phone,
        "role": role,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          pendingVerificationEmail: email,
          successMessage: "Account created! Verification code sent to $email.",
        );
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data["detail"] ?? "Signup failed. Email may be already registered.";
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "An error occurred during signup");
    }
    return false;
  }

  Future<bool> sendOtp(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiClient.post("/auth/send-otp", data: {"email": email});
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          pendingVerificationEmail: email,
          successMessage: "Verification code sent to $email",
        );
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data["detail"] ?? "Failed to send verification code.";
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Error sending OTP");
    }
    return false;
  }

  Future<bool> verifyOtp(String email, String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiClient.post("/auth/verify-otp", data: {
        "email": email,
        "code": code,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          successMessage: "Email verified successfully!",
        );
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data["detail"] ?? "Invalid or expired verification code.";
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Error verifying OTP");
    }
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiClient.post("/auth/forgot-password", data: {"email": email});
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          pendingVerificationEmail: email,
          successMessage: "Password reset instructions sent to $email.",
        );
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data["detail"] ?? "Error processing password reset.";
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Error sending reset email");
    }
    return false;
  }

  Future<bool> verifyIdentity(String idNumber, String collegeOrCompany) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiClient.post("/auth/verify-identity", data: {
        "id_number": idNumber,
        "college_or_company": collegeOrCompany,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          successMessage: "Identity verification submitted successfully!",
        );
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data["detail"] ?? "Identity verification failed.";
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Error submitting identity verification");
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

  Future<bool> loginWithGoogle({
    required String email,
    String? name,
    String? picture,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
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

