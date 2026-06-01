import 'package:flutter/material.dart';
import 'package:fit_app/models/onboarding_data.dart';
import 'package:fit_app/services/user_service.dart';
import 'package:fit_app/models/update_profile_model.dart';

class NutritionPreferencesScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const NutritionPreferencesScreen({super.key, required this.onboardingData});

  @override
  State<NutritionPreferencesScreen> createState() =>
      _NutritionPreferencesScreenState();
}

class _NutritionPreferencesScreenState
    extends State<NutritionPreferencesScreen> {
  String selectedEatingStyle = 'Normal';
  List<String> selectedAllergies = [];
  bool _isLoading = false;

  final List<String> eatingStyles = [
    'Normal',
    'Vegetarian',
    'Vegan',
    'Keto',
  ];

  final List<String> allergyOptions = [
    'Gluten',
    'Lactose',
    'Eggs',
    'Nuts',
    'Other',
  ];

  Widget _buildEatingStyleOption(String style) {
    bool isSelected = selectedEatingStyle == style;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEatingStyle = style;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFCDFF00) : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          style,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAllergyOption(String allergy) {
    bool isSelected = selectedAllergies.contains(allergy);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedAllergies.remove(allergy);
          } else {
            selectedAllergies.add(allergy);
          }
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFCDFF00) : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? const Color(0xFFCDFF00) : Colors.grey,
                  width: 2,
                ),
                color:
                    isSelected ? const Color(0xFFCDFF00) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              allergy,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onGetStarted() async {
    // Save final step data
    widget.onboardingData.eatingStyle = selectedEatingStyle;
    widget.onboardingData.allergies = List<String>.from(selectedAllergies);

    print('[Onboarding] Step 7 — eatingStyle: ${widget.onboardingData.eatingStyle}, '
        'allergies: ${widget.onboardingData.allergies}');

    setState(() => _isLoading = true);

    final data = widget.onboardingData;
    final userService = UserService();

    try {
      print('[Onboarding] Gender before request: ${data.gender}');
      
      final response = await userService.updateProfile(
        UpdateProfileRequest(
          gender: data.gender, // "Male" or "Female" as-is
          height: data.heightCm,
          weight: data.weightKg,
          fitnessGoal: OnboardingData.mapFitnessGoal(data.fitnessGoal),
          fitnessLevel: OnboardingData.mapFitnessLevel(data.fitnessLevel),
          healthConditions: data.buildHealthConditions(),
          dietaryPreferences: data.buildDietaryPreferences(),
          onboardingCompleted: true,
        ),
      );

      if (response.isSuccess) {
        print('[Onboarding] Profile update succeeded');
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Success — navigate to Home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw Exception(response.message ?? 'Failed to save profile');
      }
    } catch (e) {
      debugPrint('[Onboarding] Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'Build Your Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tailor your experience',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDFF00),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '7/7',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Nutrition Preferences',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize your meal plans',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'What is your primary eating style?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ...eatingStyles.map((style) => _buildEatingStyleOption(style)),

                    const SizedBox(height: 24),

                    const Text(
                      'Do you have any allergies?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ...allergyOptions.map((allergy) => _buildAllergyOption(allergy)),
                  ],
                ),
              ),
            ),

            // Get Started Button — fixed at bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCDFF00),
                      disabledBackgroundColor:
                          const Color(0xFFCDFF00).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
