import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cohabio/core/network/api_client.dart';

class ChatRoomsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  ChatRoomsNotifier() : super(const AsyncValue.loading()) {
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    state = const AsyncValue.loading();
    try {
      final response = await apiClient.get("/chat/rooms");
      if (response.statusCode == 200) {
        state = AsyncValue.data(response.data);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final chatRoomsProvider = StateNotifierProvider<ChatRoomsNotifier, AsyncValue<List<dynamic>>>((ref) {
  return ChatRoomsNotifier();
});

class ActiveChatNotifier extends StateNotifier<List<dynamic>> {
  final String roomId;
  WebSocket? _webSocket;
  final _storage = const FlutterSecureStorage();

  ActiveChatNotifier(this.roomId) : super([]) {
    fetchMessages();
    connectWebSocket();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await apiClient.get("/chat/rooms/$roomId/messages");
      if (response.statusCode == 200) {
        state = response.data;
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  Future<void> connectWebSocket() async {
    try {
      final token = await _storage.read(key: "access_token");
      if (token == null) return;

      final host = Platform.isAndroid ? "10.0.2.2:8001" : "localhost:8001";
      final wsUrl = "ws://$host/api/v1/chat/ws/$roomId?token=$token";

      _webSocket = await WebSocket.connect(wsUrl);
      _webSocket!.listen((data) {
        final Map<String, dynamic> event = json.decode(data);
        if (event["type"] == "message") {
          state = [...state, event];
        }
      }, onError: (err) {
        print("WebSocket Error: $err");
      }, onDone: () {
        print("WebSocket Closed");
      });
    } catch (e) {
      print("Error connecting WebSocket: $e");
    }
  }

  void sendMessage(String content) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      _webSocket!.add(json.encode({
        "type": "message",
        "content": content,
      }));
    }
  }

  @override
  void dispose() {
    _webSocket?.close();
    super.dispose();
  }
}

final activeChatProvider = StateNotifierProvider.family<ActiveChatNotifier, List<dynamic>, String>((ref, roomId) {
  final notifier = ActiveChatNotifier(roomId);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
