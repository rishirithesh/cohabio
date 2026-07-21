import 'package:flutter/material.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';

class AiRelocationScreen extends StatefulWidget {
  const AiRelocationScreen({Key? key}) : super(key: key);

  @override
  State<AiRelocationScreen> createState() => _AiRelocationScreenState();
}

class _AiRelocationScreenState extends State<AiRelocationScreen> {
  final _queryController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "isAi": true,
      "text": "Hello! I am your Cohabio Relocation Assistant powered by Gemini. Ask me about neighborhoods, moving budgets, packing timelines, or target cities! Try: 'Moving to Bangalore with 15k rent budget'."
    }
  ];
  bool _isLoading = false;

  void _handleSend() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({"isAi": false, "text": query});
      _queryController.clear();
      _isLoading = true;
    });

    // Simulate AI response logic
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add({
          "isAi": true,
          "text": "Based on your request, here are top areas in Bangalore:\n\n"
              "1. **HSR Layout**: Excellent startup hub, PG rents average ₹10k - ₹15k. Highly connected.\n"
              "2. **Koramangala**: Active social life, great for fresh graduates. Single room range ₹12k - ₹18k.\n"
              "3. **Bellandur**: Closest to major IT parks, budget range ₹13k - ₹17k.\n\n"
              "Would you like me to recommend matching roommates in these areas?"
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Relocation Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isAi = msg["isAi"];

                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isAi
                          ? const Color(0xFFF1F5F9)
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: isAi ? Radius.zero : const Radius.circular(14),
                        bottomRight: isAi ? const Radius.circular(14) : Radius.zero,
                      ),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: isAi ? Colors.black87 : Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      hintText: 'Ask Cohabio AI relocation guide...',
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
