import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';
import 'package:cohabio/core/providers/roommates_provider.dart';

class RoommateSwipeScreen extends ConsumerStatefulWidget {
  const RoommateSwipeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RoommateSwipeScreen> createState() => _RoommateSwipeScreenState();
}

class _RoommateSwipeScreenState extends ConsumerState<RoommateSwipeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final roommatesAsync = ref.watch(roommatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logo.png', width: 28, height: 28, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.search)),
            ),
            const SizedBox(width: 10),
            const Text('Roommate Discovery', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            ref.read(roommatesProvider.notifier).fetchRecommendations();
          }),
        ],
      ),
      body: roommatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error fetching matches: $err")),
        data: (candidates) {
          if (candidates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "You've swiped on everyone! Check back later for new compatible roommates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          if (_currentIndex >= candidates.length) {
            _currentIndex = 0;
          }

          final candidate = candidates[_currentIndex];
          final profile = candidate["user_profile"];
          final lifestyle = profile["lifestyle_preferences"] ?? {};
          final score = candidate["match_score"] ?? 50;

          // Compile tags
          final List<String> tags = [];
          if (lifestyle["sleep_schedule"] != null) tags.add(lifestyle["sleep_schedule"].toString().toUpperCase());
          if (lifestyle["food_pref"] != null) tags.add(lifestyle["food_pref"].toString().toUpperCase());
          if (lifestyle["cleanliness_rating"] != null) tags.add("Cleanliness: ${lifestyle["cleanliness_rating"]}/5");

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: CohabioCard(
                    padding: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 260,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  image: DecorationImage(
                                    image: NetworkImage(profile["avatar_url"] ?? "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: CohabioMatchBadge(score: score),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${profile["full_name"]}, ${profile["age"] ?? 22}',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      '₹${profile["budget_max"]} / mo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${profile["occupation"] ?? "Student"} • ${profile["college"] ?? profile["company"] ?? "University"}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: tags.map((t) => CohabioChip(label: t, isSelected: true)).toList(),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  profile["bio"] ?? "Relocating to a new city!",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'btn1',
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.close, color: Colors.red, size: 28),
                      onPressed: () => _handleSwipe(profile["user_id"], "disliked"),
                    ),
                    FloatingActionButton(
                      heroTag: 'btn2',
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.star, color: Colors.amber, size: 28),
                      onPressed: () => _handleSwipe(profile["user_id"], "liked"),
                    ),
                    FloatingActionButton(
                      heroTag: 'btn3',
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.favorite, color: Colors.white, size: 28),
                      onPressed: () => _handleSwipe(profile["user_id"], "liked"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSwipe(String targetUserId, String action) async {
    final response = await ref.read(roommatesProvider.notifier).swipe(targetUserId, action);
    if (response != null && response["is_match"] == true) {
      // Show Match Dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("🎉 It's a Match!"),
          content: const Text("You and your roommate are compatible. Direct chat is now unlocked!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex++;
                });
              },
              child: const Text("Awesome"),
            )
          ],
        ),
      );
    } else {
      setState(() {
        _currentIndex++;
      });
    }
  }
}
