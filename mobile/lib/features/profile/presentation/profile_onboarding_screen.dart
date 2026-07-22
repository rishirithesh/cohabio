import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';
import 'package:cohabio/core/providers/profile_provider.dart';

class ProfileOnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const ProfileOnboardingScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  ConsumerState<ProfileOnboardingScreen> createState() => _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends ConsumerState<ProfileOnboardingScreen> {
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _budgetController = TextEditingController();
  
  String _foodPref = "any";
  String _sleepSchedule = "flexible";
  int _cleanliness = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).fetchProfile().then((_) {
        final profileState = ref.read(profileProvider).value;
        if (profileState != null) {
          setState(() {
            _nameController.text = profileState["full_name"] ?? "";
            _collegeController.text = profileState["college"] ?? "";
            _budgetController.text = (profileState["budget_max"] ?? 10000.0).toString();
            
            final lifestyle = profileState["lifestyle_preferences"];
            if (lifestyle != null) {
              _foodPref = lifestyle["food_pref"] ?? "any";
              _sleepSchedule = lifestyle["sleep_schedule"] ?? "flexible";
              _cleanliness = lifestyle["cleanliness_rating"] ?? 3;
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final budgetText = _budgetController.text.trim();

    if (name.isEmpty || budgetText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and budget.')),
      );
      return;
    }

    final budget = double.tryParse(budgetText) ?? 10000.0;

    setState(() => _isLoading = true);

    final success = await ref.read(profileProvider.notifier).updateProfile({
      "full_name": name,
      "age": 22,
      "gender": "Male",
      "occupation": "Student",
      "college": _collegeController.text.trim(),
      "home_city": "Delhi",
      "current_city": "Bangalore",
      "budget_min": 0.00,
      "budget_max": budget,
      "bio": "Excited to relocate!",
      "lifestyle": {
        "food_pref": _foodPref,
        "smoking": false,
        "drinking": "socially",
        "pets": "no",
        "sleep_schedule": _sleepSchedule,
        "work_schedule": "flexible",
        "cleanliness_rating": _cleanliness,
        "interests": ["Coding", "Gaming"]
      }
    });

    setState(() => _isLoading = false);

    if (success) {
      widget.onComplete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about your lifestyle preferences to find the best matching roommates.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _collegeController,
              decoration: const InputDecoration(labelText: 'College / Company'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Budget (INR)',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 24),
            const Text('Food Preference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                CohabioChip(
                  label: 'Vegetarian',
                  isSelected: _foodPref == "vegetarian",
                  onTap: () => setState(() => _foodPref = "vegetarian"),
                ),
                const SizedBox(width: 8),
                CohabioChip(
                  label: 'Non-Vegetarian',
                  isSelected: _foodPref == "non-veg",
                  onTap: () => setState(() => _foodPref = "non-veg"),
                ),
                const SizedBox(width: 8),
                CohabioChip(
                  label: 'Vegan',
                  isSelected: _foodPref == "vegan",
                  onTap: () => setState(() => _foodPref = "vegan"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Sleep Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                CohabioChip(
                  label: 'Early Bird',
                  isSelected: _sleepSchedule == "early",
                  onTap: () => setState(() => _sleepSchedule = "early"),
                ),
                const SizedBox(width: 8),
                CohabioChip(
                  label: 'Night Owl',
                  isSelected: _sleepSchedule == "night_owl",
                  onTap: () => setState(() => _sleepSchedule = "night_owl"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Cleanliness Level: $_cleanliness / 5', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Slider(
              value: _cleanliness.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (val) => setState(() => _cleanliness = val.toInt()),
            ),
            const SizedBox(height: 36),
            CohabioPrimaryButton(
              label: 'Save & Continue',
              isLoading: _isLoading,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
