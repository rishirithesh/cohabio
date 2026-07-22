import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/providers/notification_provider.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF16A34A)),
            const SizedBox(width: 10),
            const Text('Notification Center', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationProvider.notifier).markAllAsRead();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notificationProvider.notifier).fetchNotifications();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Text(
                  'Unread (${state.unreadCount})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569)),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.send_outlined, size: 16),
                  label: const Text('Test Notification', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    _showTestNotificationDialog(context, ref);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No notifications yet!', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: item.isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getTypeColor(item.type).withOpacity(0.15),
                                child: Icon(_getTypeIcon(item.type), color: _getTypeColor(item.type)),
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(item.message, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.createdAt.replaceAll('T', ' ').substring(0, 16),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (!item.isRead) {
                                  ref.read(notificationProvider.notifier).markAsRead(item.id);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Opening deep link: ${item.deepLink ?? "/"}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  static IconData _getTypeIcon(String type) {
    switch (type) {
      case 'MATCH':
        return Icons.favorite;
      case 'MESSAGE':
        return Icons.chat_bubble_outline;
      case 'VERIFICATION':
        return Icons.verified_user_outlined;
      case 'SECURITY':
        return Icons.security;
      default:
        return Icons.notifications;
    }
  }

  static Color _getTypeColor(String type) {
    switch (type) {
      case 'MATCH':
        return const Color(0xFF16A34A);
      case 'MESSAGE':
        return const Color(0xFF38BDF8);
      case 'VERIFICATION':
        return const Color(0xFF8B5CF6);
      case 'SECURITY':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  void _showTestNotificationDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: "🎉 New 94% Roommate Match!");
    final msgController = TextEditingController(text: "Rohan Sharma swiped right on your profile! Check out their preferences.");
    String selectedType = "MATCH";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Test Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "MATCH", child: Text("Roommate Match Alert")),
                DropdownMenuItem(value: "MESSAGE", child: Text("Direct Message Alert")),
                DropdownMenuItem(value: "VERIFICATION", child: Text("Identity Verification Alert")),
                DropdownMenuItem(value: "SECURITY", child: Text("Security Alert")),
              ],
              onChanged: (val) => selectedType = val!,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(notificationProvider.notifier).sendTestNotification(
                type: selectedType,
                title: titleController.text,
                message: msgController.text,
              );
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification dispatched across Email, Push & In-App!')),
                );
              }
            },
            child: const Text('Dispatch Now 🚀'),
          ),
        ],
      ),
    );
  }
}
