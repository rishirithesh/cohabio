import 'package:flutter/material.dart';
import 'package:cohabio/core/widgets/cohabio_ui.dart';

class ProfileOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const ProfileOnboardingScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<ProfileOnboardingScreen> createState() => _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  final _nameController = TextEditingController(text: "Aravind Nair");
  final _collegeController = TextEditingController(text: "PES University");
  final _budgetController = TextEditingController(text: "12000");
  
  String _foodPref = "Veg";
  String _sleepSchedule = "Night Owl";
  int _cleanliness = 4;

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
                  isSelected: _foodPref == "Veg",
                  onTap: () => setState(() => _foodPref = "Veg"),
                ),
                const SizedBox(width: 8),
                CohabioChip(
                  label: 'Non-Vegetarian',
                  isSelected: _foodPref == "Non-Veg",
                  onTap: () => setState(() => _foodPref = "Non-Veg"),
                ),
                const SizedBox(width: 8),
                CohabioChip(
                  label: 'Vegan',
                  isSelected: _foodPref == "Vegan",
                  onTap: () => setState(() => _foodPref = "Vegan"),
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
                  isSelected: _sleepSchedule == "Early Bird",
                  onTap: () => setState(() => _sleepSchedule = "Early Bird"),
                ),
                const SizedBox(width: 8),
                CohabioChip(
                  label: 'Night Owl',
                  isSelected: _sleepSchedule == "Night Owl",
                  onTap: () => setState(() => _sleepSchedule = "Night Owl"),
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
              onPressed: widget.onComplete,
            ),
          ],
        ),
      ),
    );
  }
}
