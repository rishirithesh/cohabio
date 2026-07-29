import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/providers/housing_provider.dart';

class HousingScreen extends ConsumerStatefulWidget {
  const HousingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HousingScreen> createState() => _HousingScreenState();
}

class _HousingScreenState extends ConsumerState<HousingScreen> {
  String _selectedRoomType = 'All';
  String _selectedCity = 'Bangalore';
  double _priceMax = 50000;

  final List<String> _roomTypes = ['All', 'single_room', 'shared_room', 'full_apartment', 'PG'];

  @override
  Widget build(BuildContext context) {
    final housingState = ref.watch(housingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.home_work_rounded, color: Color(0xFF22C55E)),
            SizedBox(width: 8),
            Text('Housing Marketplace', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              ref.read(housingProvider.notifier).fetchProperties(
                city: _selectedCity,
                roomType: _selectedRoomType,
                priceMax: _priceMax,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1E293B).withOpacity(0.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Type Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roomTypes.map((type) {
                      final isSelected = _selectedRoomType == type;
                      final label = type == 'All'
                          ? 'All Types'
                          : type.replaceAll('_', ' ').toUpperCase();

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF22C55E),
                          backgroundColor: const Color(0xFF334155),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedRoomType = type);
                              ref.read(housingProvider.notifier).fetchProperties(
                                city: _selectedCity,
                                roomType: _selectedRoomType,
                                priceMax: _priceMax,
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Listings List
          Expanded(
            child: housingState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF22C55E)),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load housing listings: $err',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
                      onPressed: () {
                        ref.read(housingProvider.notifier).fetchProperties();
                      },
                      child: const Text('Retry'),
                    )
                  ],
                ),
              ),
              data: (properties) {
                if (properties.isEmpty) {
                  return const Center(
                    child: Text(
                      'No housing listings found for selected filters.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final item = properties[index];
                    final title = item['title'] ?? 'Listing ${index + 1}';
                    final address = item['address'] ?? 'Bangalore, India';
                    final price = item['price_per_month'] ?? 15000;
                    final roomType = item['room_type'] ?? 'shared_room';
                    final isBookmarked = item['is_bookmarked'] ?? false;
                    final propertyId = item['id'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Banner Placeholder
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: const Color(0xFF334155),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1E293B),
                                  const Color(0xFF0F172A).withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      roomType.replaceAll('_', ' ').toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(
                                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                      color: isBookmarked ? const Color(0xFF38BDF8) : Colors.white70,
                                    ),
                                    onPressed: () {
                                      if (propertyId != null) {
                                        ref.read(housingProvider.notifier).toggleBookmark(propertyId.toString());
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '₹$price/mo',
                                      style: const TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.white54),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        address,
                                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF38BDF8),
                                      side: const BorderSide(color: Color(0xFF38BDF8)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.info_outline, size: 18),
                                    label: const Text('View Property Details'),
                                    onPressed: () {
                                      _showPropertyDetailsModal(context, item);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  void _showPropertyDetailsModal(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final title = item['title'] ?? 'Housing Property';
        final desc = item['description'] ?? 'No detailed description available.';
        final price = item['price_per_month'] ?? 0;
        final deposit = item['deposit'] ?? 0;
        final address = item['address'] ?? '';
        final roomType = item['room_type'] ?? '';

        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '📍 $address',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoBadge('Monthly Rent', '₹$price'),
                  _infoBadge('Security Deposit', '₹$deposit'),
                  _infoBadge('Room Type', roomType.replaceAll('_', ' ')),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                  label: const Text(
                    'Contact Owner / Flatmate',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connecting to owner chat room...')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoBadge(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
