import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/network/api_client.dart';
import 'package:dio/dio.dart';

class HousingNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  HousingNotifier() : super(const AsyncValue.loading()) {
    fetchProperties();
  }

  Future<void> fetchProperties({String? city, String? roomType, double? priceMax}) async {
    state = const AsyncValue.loading();
    try {
      final Map<String, dynamic> params = {};
      if (city != null && city.isNotEmpty) params["city"] = city;
      if (roomType != null && roomType != "All") params["room_type"] = roomType;
      if (priceMax != null) params["price_max"] = priceMax;

      final response = await apiClient.get("/housing/", queryParameters: params);
      if (response.statusCode == 200) {
        state = AsyncValue.data(response.data);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> toggleBookmark(String propertyId) async {
    try {
      final response = await apiClient.post("/housing/$propertyId/bookmark");
      if (response.statusCode == 200) {
        // Optimistically update bookmark state
        if (state.hasValue) {
          final updated = state.value!.map((prop) {
            if (prop["id"] == propertyId) {
              final isBookmarked = response.data["status"] == "bookmarked";
              return {...prop, "is_bookmarked": isBookmarked};
            }
            return prop;
          }).toList();
          state = AsyncValue.data(updated);
        }
        return true;
      }
    } catch (e) {
      print("Error toggling bookmark: $e");
    }
    return false;
  }
}

final housingProvider = StateNotifierProvider<HousingNotifier, AsyncValue<List<dynamic>>>((ref) {
  return HousingNotifier();
});
