import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/providers/chat_provider.dart';
import 'package:cohabio/features/chat/presentation/chat_conversation_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsState = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text('Messages & Direct Chats', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.read(chatRoomsProvider.notifier).fetchRooms(),
          )
        ],
      ),
      body: roomsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.forum_outlined, color: Colors.white38, size: 48),
              const SizedBox(height: 12),
              Text(
                'No active conversations yet.\nMatch with roommates or connect in communities to start messaging!',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
                onPressed: () => ref.read(chatRoomsProvider.notifier).fetchRooms(),
                child: const Text('Refresh', style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat_rounded, size: 48, color: Color(0xFF38BDF8)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Chat Inbox is Empty',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Swipe on prospective roommates or join a community group to start real-time conversations!',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final roomId = room['id'] ?? '';
              final roomType = room['type'] ?? 'direct';
              final participants = room['participants'] as List? ?? [];
              final partnerName = participants.isNotEmpty
                  ? (participants.first['full_name'] ?? 'Roommate')
                  : 'Roommate Match';
              final lastMsg = room['last_message']?['content'] ?? 'Start chatting now!';

              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF38BDF8).withOpacity(0.2),
                    child: Text(
                      partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'C',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    partnerName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    lastMsg,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatConversationScreen(
                          roomId: roomId,
                          title: partnerName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
