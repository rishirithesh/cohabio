import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/network/api_client.dart';
import 'package:dio/dio.dart';

class ChatMessage {
  final String text;
  final bool isAi;
  ChatMessage({required this.text, required this.isAi});
}

class AiAssistantNotifier extends StateNotifier<List<ChatMessage>> {
  AiAssistantNotifier()
      : super([
          ChatMessage(
            text:
                "Hello! I am your Cohabio Relocation Assistant powered by Gemini. Ask me about neighborhoods, moving budgets, packing timelines, or target cities! Try: 'Moving to Bangalore with 15k rent budget'.",
            isAi: true,
          )
        ]);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendQuery(String userQuery) async {
    state = [...state, ChatMessage(text: userQuery, isAi: false)];
    _isLoading = true;
    
    try {
      // First try parsing using natural language parser endpoint
      final parseResponse = await apiClient.get("/relocation/search/parse", queryParameters: {"query": userQuery});
      
      String city = "Bangalore";
      double budget = 12000.0;
      List<String> preferences = [];
      
      if (parseResponse.statusCode == 200) {
        city = parseResponse.data["city"] ?? "Bangalore";
        budget = (parseResponse.data["budget_max"] ?? 12000.0).toDouble();
        preferences = List<String>.from(parseResponse.data["preferences"] ?? []);
      }

      // Send structured query to relocation assistant
      final response = await apiClient.post(
        "/relocation/assistant",
        data: {
          "current_city": "Delhi", // Default origin
          "target_city": city,
          "budget": budget,
          "preferences": preferences,
        },
      );

      if (response.statusCode == 200) {
        final advice = response.data["advice"];
        state = [...state, ChatMessage(text: advice, isAi: true)];
      } else {
        state = [...state, ChatMessage(text: "Failed to get advice. Please try again.", isAi: true)];
      }
    } catch (e) {
      state = [...state, ChatMessage(text: "Error contacting relocation assistant: $e", isAi: true)];
    } finally {
      _isLoading = false;
    }
  }
}

final aiAssistantProvider = StateNotifierProvider<AiAssistantNotifier, List<ChatMessage>>((ref) {
  return AiAssistantNotifier();
});
