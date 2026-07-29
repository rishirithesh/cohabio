import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/providers/ai_assistant_provider.dart';

class AiRelocationScreen extends ConsumerStatefulWidget {
  const AiRelocationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AiRelocationScreen> createState() => _AiRelocationScreenState();
}

class _AiRelocationScreenState extends ConsumerState<AiRelocationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();

  // Moving Checklist State
  final List<Map<String, dynamic>> _checklistItems = [
    {'task': 'Define Budget & Target Neighborhoods', 'completed': true, 'category': '1 Month Before'},
    {'task': 'Swipe & Finalize Compatible Roommates', 'completed': true, 'category': '1 Month Before'},
    {'task': 'Shortlist Verified Housing Properties', 'completed': false, 'category': '2 Weeks Before'},
    {'task': 'Schedule Video Tours / In-person Visits', 'completed': false, 'category': '2 Weeks Before'},
    {'task': 'Review Lease Agreement & Pay Security Deposit', 'completed': false, 'category': '1 Week Before'},
    {'task': 'Book Packers & Movers Service', 'completed': false, 'category': '1 Week Before'},
    {'task': 'Setup Local Wi-Fi & Electricity Utilities', 'completed': false, 'category': 'Day 1'},
    {'task': 'Join Neighborhood Community Group', 'completed': false, 'category': 'Day 1'},
  ];

  // Relocation Budget Calculator State
  double _monthlyRent = 15000;
  double _depositMonths = 2;
  double _movingCost = 4000;
  double _utilitiesCost = 2500;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    _queryController.clear();
    ref.read(aiAssistantProvider.notifier).sendQuery(query).then((_) {
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF22C55E)),
            SizedBox(width: 8),
            Text('AI & Relocation Toolkit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF22C55E),
          labelColor: const Color(0xFF22C55E),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.psychology), text: 'AI Advisor'),
            Tab(icon: Icon(Icons.checklist_rtl), text: 'Checklist'),
            Tab(icon: Icon(Icons.calculate_outlined), text: 'Calculator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAiChatTab(),
          _buildChecklistTab(),
          _buildCalculatorTab(),
        ],
      ),
    );
  }

  // --- 1. AI CHAT TAB ---
  Widget _buildAiChatTab() {
    final messages = ref.watch(aiAssistantProvider);
    final notifier = ref.watch(aiAssistantProvider.notifier);

    return Column(
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
                    color: isAi ? const Color(0xFF1E293B) : const Color(0xFF22C55E),
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
                      color: isAi ? Colors.white : Colors.black,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: isAi ? FontWeight.normal : FontWeight.w600,
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
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF22C55E)),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF1E293B),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _handleSend(),
                  decoration: const InputDecoration(
                    hintText: 'Ask Gemini AI relocation guide...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF22C55E)),
                onPressed: _handleSend,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. CHECKLIST TAB ---
  Widget _buildChecklistTab() {
    final completedCount = _checklistItems.where((i) => i['completed'] == true).length;
    final progress = _checklistItems.isNotEmpty ? completedCount / _checklistItems.length : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Relocation Preparedness', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${(progress * 100).toInt()}% Done', style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF334155),
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Interactive Moving Roadmap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                final item = _checklistItems[index];
                final isDone = item['completed'] == true;

                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    activeColor: const Color(0xFF22C55E),
                    checkColor: Colors.black,
                    title: Text(
                      item['task'],
                      style: TextStyle(
                        color: isDone ? Colors.white54 : Colors.white,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        fontWeight: isDone ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      item['category'],
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                    ),
                    value: isDone,
                    onChanged: (val) {
                      setState(() {
                        _checklistItems[index]['completed'] = val;
                      });
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

  // --- 3. CALCULATOR TAB ---
  Widget _buildCalculatorTab() {
    final depositTotal = _monthlyRent * _depositMonths;
    final upfrontTotal = depositTotal + _monthlyRent + _movingCost + _utilitiesCost;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Total Relocation Cost', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('₹${upfrontTotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 32)),
                const SizedBox(height: 4),
                const Text('Includes 1st month rent, security deposit, movers & setup.', style: TextStyle(color: Colors.black87, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Cost Breakdown Inputs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          // Monthly Rent Slider
          _buildSliderCard('Monthly Rent Target (₹)', _monthlyRent, 5000, 80000, (val) {
            setState(() => _monthlyRent = val);
          }),

          // Security Deposit Months Slider
          _buildSliderCard('Security Deposit (${_depositMonths.toInt()} Months)', _depositMonths, 1, 6, (val) {
            setState(() => _depositMonths = val);
          }),

          // Moving Van & Transport
          _buildSliderCard('Movers & Transport (₹)', _movingCost, 1000, 25000, (val) {
            setState(() => _movingCost = val);
          }),

          // Utility Setup
          _buildSliderCard('Wi-Fi & Utility Setup (₹)', _utilitiesCost, 500, 10000, (val) {
            setState(() => _utilitiesCost = val);
          }),
        ],
      ),
    );
  }

  Widget _buildSliderCard(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              activeColor: const Color(0xFF22C55E),
              inactiveColor: const Color(0xFF334155),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
