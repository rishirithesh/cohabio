import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/network/api_client.dart';
import 'package:dio/dio.dart';

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? relatedEntityId;
  final String? deepLink;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedEntityId,
    this.deepLink,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      relatedEntityId: json['related_entity_id'],
      deepLink: json['deep_link'],
      createdAt: json['created_at'],
    );
  }
}

class NotificationState {
  final List<NotificationItem> items;
  final int unreadCount;
  final bool isLoading;

  NotificationState({
    this.items = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState()) {
    fetchNotifications();
    registerDeviceToken();
  }

  Future<void> fetchNotifications() async {
    state = NotificationState(items: state.items, unreadCount: state.unreadCount, isLoading: true);
    try {
      final response = await apiClient.get("/notifications");
      if (response.statusCode == 200) {
        final list = (response.data["notifications"] as List)
            .map((e) => NotificationItem.fromJson(e))
            .toList();
        final unread = response.data["unread_count"] ?? 0;
        state = NotificationState(items: list, unreadCount: unread, isLoading: false);
      }
    } catch (e) {
      state = NotificationState(items: state.items, unreadCount: state.unreadCount, isLoading: false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await apiClient.post("/notifications/$notificationId/read");
      fetchNotifications();
    } catch (e) {
      print("Error marking notification read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await apiClient.post("/notifications/read-all");
      fetchNotifications();
    } catch (e) {
      print("Error marking all read: $e");
    }
  }

  Future<void> registerDeviceToken() async {
    try {
      // Register device FCM / Mobile Push token with backend
      await apiClient.post("/notifications/device-token", data: {
        "token": "fcm_token_cohabio_device_demo_123456789",
        "platform": "android"
      });
    } catch (e) {
      print("Device token registration error: $e");
    }
  }

  Future<bool> sendTestNotification({required String type, required String title, required String message}) async {
    try {
      final response = await apiClient.post("/notifications/test", data: {
        "type": type,
        "title": title,
        "message": message,
      });
      if (response.statusCode == 200) {
        fetchNotifications();
        return true;
      }
    } catch (e) {
      print("Test notification error: $e");
    }
    return false;
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
