import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  double _dragOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    final roommatesAsync = ref.watch(roommatesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.style_rounded, color: Color(0xFF22C55E), size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Roommate Discovery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Refresh recommendations',
            onPressed: () {
              setState(() => _currentIndex = 0);
              ref.read(roommatesProvider.notifier).fetchRecommendations();
            },
          ),
        ],
      ),
      body: roommatesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF22C55E)),
        ),
        error: (err, stack) => Center(
          child: Text(
            "Error fetching roommate candidates: $err",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (candidates) {
          if (candidates.isEmpty || _currentIndex >= candidates.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.all_inclusive_rounded, size: 54, color: Color(0xFF22C55E)),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 20),
                    const Text(
                      "You've explore all current matches!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "New verified students and professionals arrive daily. Tap below to reload candidates.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _currentIndex = 0);
                        ref.read(roommatesProvider.notifier).fetchRecommendations();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reload Candidates'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final candidate = candidates[_currentIndex];
          final profile = candidate["user_profile"];
          final lifestyle = profile["lifestyle_preferences"] ?? {};
          final score = candidate["match_score"] ?? 85;

          final List<String> tags = [];
          if (lifestyle["sleep_schedule"] != null) tags.add(lifestyle["sleep_schedule"].toString().toUpperCase());
          if (lifestyle["food_pref"] != null) tags.add(lifestyle["food_pref"].toString().toUpperCase());
          if (lifestyle["cleanliness_rating"] != null) tags.add("Cleanliness: ${lifestyle["cleanliness_rating"]}/5");
          if (profile["home_city"] != null) tags.add("From: ${profile["home_city"]}");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              children: [
                // Swipeable Card Stack Container
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _dragOffset += details.delta.dx;
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_dragOffset > 100) {
                        _handleSwipe(profile["user_id"], "liked");
                      } else if (_dragOffset < -100) {
                        _handleSwipe(profile["user_id"], "disliked");
                      }
                      setState(() {
                        _dragOffset = 0.0;
                      });
                    },
                    child: Transform.translate(
                      offset: Offset(_dragOffset, 0),
                      child: Transform.rotate(
                        angle: _dragOffset / 1000,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Picture & Match Badge Stack
                                  Stack(
                                    children: [
                                      Image.network(
                                        profile["avatar_url"] ?? "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500",
                                        height: 280,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 280,
                                          color: const Color(0xFF16A34A).withOpacity(0.2),
                                          child: const Icon(Icons.person, size: 80, color: Colors.white54),
                                        ),
                                      ),
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF16A34A), Color(0xFF059669)],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF16A34A).withOpacity(0.4),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.bolt, color: Colors.amberAccent, size: 18),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$score% Match',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Profile Info Content
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${profile["full_name"]}, ${profile["age"] ?? 22}',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF22C55E).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '₹${profile["budget_max"]} / mo',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF22C55E),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${profile["occupation"] ?? "Student"} • ${profile["college"] ?? profile["company"] ?? "University"}',
                                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                        ),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: tags
                                              .map(
                                                (t) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                                                  ),
                                                  child: Text(
                                                    t,
                                                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          profile["bio"] ?? "Relocating to a new city and looking for clean, friendly flatmates!",
                                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate(key: ValueKey(_currentIndex)).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Interactive Action Buttons Row (Dislike, Bookmark, Superlike)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.close_rounded,
                      color: Colors.redAccent,
                      bgColor: Colors.red.withOpacity(0.15),
                      onPressed: () => _handleSwipe(profile["user_id"], "disliked"),
                    ),
                    _buildActionButton(
                      icon: Icons.star_rounded,
                      color: Colors.amber,
                      bgColor: Colors.amber.withOpacity(0.15),
                      onPressed: () => _handleSwipe(profile["user_id"], "liked"),
                    ),
                    _buildActionButton(
                      icon: Icons.favorite_rounded,
                      color: Colors.white,
                      bgColor: const Color(0xFF16A34A),
                      size: 32,
                      padding: 16,
                      onPressed: () => _handleSwipe(profile["user_id"], "liked"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onPressed,
    double size = 26,
    double padding = 14,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  Future<void> _handleSwipe(String targetUserId, String action) async {
    final response = await ref.read(roommatesProvider.notifier).swipe(targetUserId, action);
    if (response != null && response["is_match"] == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.stars_rounded, color: Colors.amber, size: 54),
          title: const Text(
            "🎉 It's a Roomie Match!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "You both liked each other's profile! Direct messaging and housing share features are now unlocked.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _currentIndex++);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Chatting'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _currentIndex++);
    }
  }
}
