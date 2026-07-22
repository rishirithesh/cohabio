import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';
import 'package:cohabio/core/providers/communities_provider.dart';

class CommunitiesFeedScreen extends ConsumerStatefulWidget {
  const CommunitiesFeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunitiesFeedScreen> createState() => _CommunitiesFeedScreenState();
}

class _CommunitiesFeedScreenState extends ConsumerState<CommunitiesFeedScreen> {
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "City", "College", "Language", "Profession", "Interests"];

  @override
  Widget build(BuildContext context) {
    final communitiesAsync = ref.watch(communitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cohabio Communities', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            ref.read(communitiesProvider.notifier).fetchCommunities(category: _selectedFilter);
          }),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CohabioChip(
                    label: filter,
                    isSelected: _selectedFilter == filter,
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      ref.read(communitiesProvider.notifier).fetchCommunities(category: filter);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: communitiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error fetching communities: $err")),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text("No communities found in this category."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CohabioCard(
                        onTap: () {
                          // Show posts modal or detailed view
                          _showPostsDialog(context, item);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(item["icon_url"] ?? "https://images.unsplash.com/photo-1596176530529-78163a4f7af2?auto=format&fit=crop&w=150&q=80"),
                                  radius: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('${item["category"].toUpperCase()} • ${item["member_count"]} members', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                if (item["is_verified"])
                                  const Icon(Icons.verified, size: 20, color: Colors.blue),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(item["description"] ?? "", style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPostsDialog(BuildContext context, Map<String, dynamic> community) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final postsAsync = ref.watch(communityPostsProvider(community["id"]));
                final postController = TextEditingController();

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          Text(community["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: postsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text("Error fetching posts: $err")),
                        data: (posts) {
                          if (posts.isEmpty) {
                            return const Center(child: Text("No posts yet. Be the first to share something!"));
                          }
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: post["author_avatar"] != null ? NetworkImage(post["author_avatar"]) : null,
                                            child: post["author_avatar"] == null ? Text(post["author_name"][0]) : null,
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(post["author_name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text(post["created_at"].toString().substring(0, 10), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(post["content"]),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              post["is_liked_by_me"] == true ? Icons.favorite : Icons.favorite_border,
                                              color: post["is_liked_by_me"] == true ? Colors.red : Colors.grey,
                                            ),
                                            onPressed: () {
                                              ref.read(communityPostsProvider(community["id"]).notifier).toggleLike(post["id"]);
                                            },
                                          ),
                                          Text('${post["likes_count"]}'),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: postController,
                              decoration: const InputDecoration(
                                hintText: 'Write a post in this community...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              final text = postController.text.trim();
                              if (text.isEmpty) return;
                              final ok = await ref.read(communityPostsProvider(community["id"]).notifier).createPost(text);
                              if (ok) postController.clear();
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
