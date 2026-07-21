import 'package:flutter/material.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';

class RoommateSwipeScreen extends StatefulWidget {
  const RoommateSwipeScreen({Key? key}) : super(key: key);

  @override
  State<RoommateSwipeScreen> createState() => _RoommateSwipeScreenState();
}

class _RoommateSwipeScreenState extends State<RoommateSwipeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _candidates = [
    {
      "name": "Rohan Sharma",
      "age": 22,
      "occupation": "Software Engineer Intern @ Google",
      "college": "BITS Pilani",
      "budget": "₹15,000 / mo",
      "matchScore": 94,
      "bio": "Moving to Bangalore for 6 months internship. Huge gamer, loves football and keeps flat super clean.",
      "tags": ["Night Owl", "Vegetarian", "Clean 4/5", "Non-Smoker"],
      "image": "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80"
    },
    {
      "name": "Aanya Iyer",
      "age": 23,
      "occupation": "Data Analyst @ Amazon",
      "college": "SRM University",
      "budget": "₹18,000 / mo",
      "matchScore": 88,
      "bio": "Extremely organized, early riser, loves cooking filter coffee and pets friendly!",
      "tags": ["Early Bird", "Pet Friendly", "Clean 5/5", "Non-Smoker"],
      "image": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80"
    }
  ];

  void _nextCandidate() {
    if (_currentIndex < _candidates.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = _candidates[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roommate Discovery', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: CohabioCard(
                padding: EdgeInsets.zero,
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
                              image: NetworkImage(candidate["image"]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: CohabioMatchBadge(score: candidate["matchScore"]),
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
                              Text(
                                '${candidate["name"]}, ${candidate["age"]}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                candidate["budget"],
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
                            candidate["occupation"],
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (candidate["tags"] as List<String>)
                                .map((t) => CohabioChip(label: t, isSelected: true))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            candidate["bio"],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  onPressed: _nextCandidate,
                ),
                FloatingActionButton(
                  heroTag: 'btn2',
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.star, color: Colors.amber, size: 28),
                  onPressed: _nextCandidate,
                ),
                FloatingActionButton(
                  heroTag: 'btn3',
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.favorite, color: Colors.white, size: 28),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Matched with ${candidate["name"]}! Chat unlock request sent.')),
                    );
                    _nextCandidate();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
