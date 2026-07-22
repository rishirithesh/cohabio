import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/network/api_client.dart';
import 'package:dio/dio.dart';

class RoommatesNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  RoommatesNotifier() : super(const AsyncValue.loading()) {
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    state = const AsyncValue.loading();
    try {
      final response = await apiClient.get("/roommates/recommendations");
      if (response.statusCode == 200) {
        state = AsyncValue.data(response.data);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Map<String, dynamic>?> swipe(String targetUserId, String action) async {
    try {
      final response = await apiClient.post(
        "/roommates/swipe",
        queryParameters: {"target_user_id": targetUserId, "action": action},
      );
      if (response.statusCode == 200) {
        // Remove swiped candidate from local list to animate off
        if (state.hasValue) {
          final remaining = state.value!.where((item) => item["user_profile"]["user_id"] != targetUserId).toList();
          state = AsyncValue.data(remaining);
        }
        return response.data;
      }
    } catch (e) {
      print("Error swiping: $e");
    }
    return null;
  }
}

final roommatesProvider = StateNotifierProvider<RoommatesNotifier, AsyncValue<List<dynamic>>>((ref) {
  return RoommatesNotifier();
});
