import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/providers/events_provider.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.event_available, color: Color(0xFF22C55E)),
            SizedBox(width: 8),
            Text('Local Events & Gatherings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.read(eventsProvider.notifier).fetchEvents(),
          )
        ],
      ),
      body: eventsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF22C55E)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load events: $err',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
                onPressed: () => ref.read(eventsProvider.notifier).fetchEvents(),
                child: const Text('Retry', style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration_outlined, color: Colors.white38, size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'No Upcoming Events Found',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to organize a flatmate meetup or coffee run!',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final eventId = event['id'];
              final title = event['title'] ?? 'Community Meetup';
              final desc = event['description'] ?? 'Connect with fellow relocators in your city!';
              final location = event['location_name'] ?? 'Bangalore Hub';
              final rsvpCount = event['rsvp_count'] ?? 0;
              final rsvpStatus = event['my_rsvp_status'];

              final isGoing = rsvpStatus == 'going';

              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '📍 LOCAL MEETUP',
                              style: TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 16, color: Colors.white54),
                              const SizedBox(width: 4),
                              Text(
                                '$rsvpCount going',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 16, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        desc,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.3),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isGoing ? const Color(0xFF22C55E) : const Color(0xFF334155),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: Icon(
                                isGoing ? Icons.check_circle : Icons.event_available,
                                color: isGoing ? Colors.black : Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                isGoing ? 'I\'m Going 🎉' : 'RSVP Going',
                                style: TextStyle(
                                  color: isGoing ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                if (eventId != null) {
                                  final newStatus = isGoing ? 'cant_go' : 'going';
                                  ref.read(eventsProvider.notifier).rsvpEvent(eventId.toString(), newStatus);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
