import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/network/api_client.dart';
import 'package:dio/dio.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      final response = await apiClient.get("/profiles/me");
      if (response.statusCode == 200) {
        state = AsyncValue.data(response.data);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put("/profiles/me", data: data);
      if (response.statusCode == 200) {
        state = AsyncValue.data(response.data);
        return true;
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
    return false;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return ProfileNotifier();
});
