import 'package:flutter/material.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';

class CommunitiesFeedScreen extends StatefulWidget {
  const CommunitiesFeedScreen({Key? key}) : super(key: key);

  @override
  State<CommunitiesFeedScreen> createState() => _CommunitiesFeedScreenState();
}

class _CommunitiesFeedScreenState extends State<CommunitiesFeedScreen> {
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "City", "College", "Language", "Profession", "Interests"];

  final List<Map<String, dynamic>> _posts = [
    {
      "author": "Priya Sharma",
      "community": "Bangalore Techies & Interns",
      "time": "2h ago",
      "content": "Hey everyone! Moving to Bangalore next month for an internship at Cisco. Any suggestions for safe PG accommodation near Marathahalli under 12k?",
      "likes": 24,
      "comments": 12,
      "isPinned": true,
    },
    {
      "author": "Karthik Rajan",
      "community": "PES University Relocation Hub",
      "time": "5h ago",
      "content": "Looking for 1 male flatmate to occupy a single room in a 3BHK flat near PES RR Campus. Rent is 14k/month including maintenance.",
      "likes": 18,
      "comments": 8,
      "isPinned": false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cohabio Communities', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
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
                    onTap: () => setState(() => _selectedFilter = filter),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CohabioCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(post["author"][0], style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post["author"], style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${post["community"]} • ${post["time"]}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const Spacer(),
                            if (post["isPinned"])
                              const Icon(Icons.push_pin, size: 18, color: Colors.amber),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(post["content"], style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.favorite_border, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${post["likes"]}'),
                            const SizedBox(width: 20),
                            Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${post["comments"]}'),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
