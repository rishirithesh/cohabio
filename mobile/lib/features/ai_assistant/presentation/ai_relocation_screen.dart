import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';
import 'package:cohabio/core/providers/ai_assistant_provider.dart';

class AiRelocationScreen extends ConsumerStatefulWidget {
  const AiRelocationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AiRelocationScreen> createState() => _AiRelocationScreenState();
}

class _AiRelocationScreenState extends ConsumerState<AiRelocationScreen> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    _queryController.clear();
    ref.read(aiAssistantProvider.notifier).sendQuery(query).then((_) {
      // Scroll to bottom after response
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiAssistantProvider);
    final notifier = ref.watch(aiAssistantProvider.notifier);

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
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isAi = msg.isAi;

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
                      msg.text,
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
          if (notifier.isLoading)
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
                    onSubmitted: (_) => _handleSend(),
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
