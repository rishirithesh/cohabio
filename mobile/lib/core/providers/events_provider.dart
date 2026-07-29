import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/network/api_client.dart';

class EventsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  EventsNotifier() : super(const AsyncValue.loading()) {
    fetchEvents();
  }

  Future<void> fetchEvents({String? communityId}) async {
    state = const AsyncValue.loading();
    try {
      final Map<String, dynamic> params = {};
      if (communityId != null) params["community_id"] = communityId;

      final response = await apiClient.get("/events/", queryParameters: params);
      if (response.statusCode == 200) {
        state = AsyncValue.data(response.data);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> rsvpEvent(String eventId, String status) async {
    try {
      final response = await apiClient.post("/events/$eventId/rsvp?status=$status");
      if (response.statusCode == 200) {
        if (state.hasValue) {
          final updated = state.value!.map((event) {
            if (event["id"] == eventId) {
              return {
                ...event,
                "my_rsvp_status": status,
                "rsvp_count": response.data["rsvp_count"] ?? event["rsvp_count"]
              };
            }
            return event;
          }).toList();
          state = AsyncValue.data(updated);
        }
        return true;
      }
    } catch (e) {
      print("Error responding to RSVP: $e");
    }
    return false;
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, AsyncValue<List<dynamic>>>((ref) {
  return EventsNotifier();
});
