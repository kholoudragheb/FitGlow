import 'package:flutter/material.dart';
import 'package:fit_app/models/onboarding_data.dart';
import 'HealthAndLimitScreen.dart';

class TrainingLocationScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const TrainingLocationScreen({super.key, required this.onboardingData});

  @override
  State<TrainingLocationScreen> createState() => _TrainingLocationScreenState();
}

class _TrainingLocationScreenState extends State<TrainingLocationScreen> {
  String? selectedLocation;
  List<String> selectedEquipment = [];

  final List<String> locations = [
    'Gym',
    'Home',
    'Home & Gym',
  ];

  final List<String> equipmentOptions = [
    'Dumbbells',
    'Bands',
    'Barbells',
    'Machines',
    'No equipment',
  ];

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
                    width: MediaQuery.of(context).size.width * (5 / 7),
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
                  '5/7',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Location Section
              const Text(
                'Where will you train?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...locations.map((loc) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLocation = loc;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedLocation == loc
                            ? const Color(0xFFCDFF00)
                            : Colors.white12,
                        width: selectedLocation == loc ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      loc,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )),

              const Spacer(),

              // Equipment Section
              const Text(
                'What equipment do you have?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: equipmentOptions.map((eq) {
                  bool isSelected = selectedEquipment.contains(eq);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedEquipment.remove(eq);
                        } else {
                          if (eq == 'No equipment') {
                            selectedEquipment.clear();
                          } else {
                            selectedEquipment.remove('No equipment');
                          }
                          selectedEquipment.add(eq);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFCDFF00)
                              : Colors.white12,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        eq,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(flex: 2),

              // Next Button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onboardingData.trainingLocation = selectedLocation;
                      widget.onboardingData.equipment =
                          List<String>.from(selectedEquipment);
                      print('[Onboarding] Step 5 — location: ${widget.onboardingData.trainingLocation}, '
                          'equipment: ${widget.onboardingData.equipment}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthAndLimitScreen(
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
