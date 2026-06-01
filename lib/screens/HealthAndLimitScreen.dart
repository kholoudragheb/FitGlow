import 'package:flutter/material.dart';
import 'package:fit_app/models/onboarding_data.dart';
import 'NutritionPreferencesScreen.dart';

class HealthAndLimitScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const HealthAndLimitScreen({super.key, required this.onboardingData});

  @override
  State<HealthAndLimitScreen> createState() => _HealthAndLimitScreenState();
}

class _HealthAndLimitScreenState extends State<HealthAndLimitScreen> {
  String hasInjuries = 'No';
  String hasChronicConditions = 'No';

  final TextEditingController _injuriesController = TextEditingController();
  final TextEditingController _chronicController = TextEditingController();

  @override
  void dispose() {
    _injuriesController.dispose();
    _chronicController.dispose();
    super.dispose();
  }

  Widget _buildYesNoToggle(
      String title, String currentValue, Function(String) onChanged) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged('Yes'),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: currentValue == 'Yes'
                      ? const Color(0xFFCDFF00)
                      : Colors.white12,
                  width: currentValue == 'Yes' ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: const Text('Yes',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged('No'),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: currentValue == 'No'
                      ? const Color(0xFFCDFF00)
                      : Colors.white12,
                  width: currentValue == 'No' ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: const Text('No',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                    width: MediaQuery.of(context).size.width * (6 / 7),
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
                  '6/7',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              const Spacer(),

              // Title
              const Text(
                'Health & Limit',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Help us keep you safe',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Injuries Section
              const Text(
                'Do you have any injuries?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildYesNoToggle('Injuries', hasInjuries, (val) {
                setState(() => hasInjuries = val);
              }),
              if (hasInjuries == 'Yes') ...[
                const SizedBox(height: 12),
                _buildTextField(
                    _injuriesController, 'Please describe the injuries area...'),
              ],

              const SizedBox(height: 24),

              // Chronic Conditions Section
              const Text(
                'Do you have any chronic conditions?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildYesNoToggle('Chronic', hasChronicConditions, (val) {
                setState(() => hasChronicConditions = val);
              }),
              if (hasChronicConditions == 'Yes') ...[
                const SizedBox(height: 12),
                _buildTextField(_chronicController,
                    'Please describe your chronic conditions...'),
              ],

              const Spacer(flex: 2),

              // Next Button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onboardingData.hasInjuries = hasInjuries == 'Yes';
                      widget.onboardingData.injuriesDescription =
                          _injuriesController.text.trim().isEmpty
                              ? null
                              : _injuriesController.text.trim();
                      widget.onboardingData.hasChronicConditions =
                          hasChronicConditions == 'Yes';
                      widget.onboardingData.chronicConditionsDescription =
                          _chronicController.text.trim().isEmpty
                              ? null
                              : _chronicController.text.trim();
                      print('[Onboarding] Step 6 — injuries: ${widget.onboardingData.hasInjuries}, '
                          'chronic: ${widget.onboardingData.hasChronicConditions}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NutritionPreferencesScreen(
                            onboardingData: widget.onboardingData,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCDFF00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
