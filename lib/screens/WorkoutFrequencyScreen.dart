import 'package:flutter/material.dart';
import 'package:fit_app/models/onboarding_data.dart';
import 'package:fit_app/screens/TrainingLocationScreen.dart';

class WorkoutFrequencyScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const WorkoutFrequencyScreen({super.key, required this.onboardingData});

  @override
  State<WorkoutFrequencyScreen> createState() => _WorkoutFrequencyScreenState();
}

class _WorkoutFrequencyScreenState extends State<WorkoutFrequencyScreen> {
  double _currentSliderValue = 3;
  String? selectedDuration;

  final List<String> durations = [
    '5-10 min',
    '15-20 min',
    '30 min',
    '45+ min',
  ];

  Widget _buildDurationOption(String duration) {
    bool isSelected = selectedDuration == duration;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDuration = duration;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFCDFF00) : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            duration,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
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
        child: Padding(
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
                    width: MediaQuery.of(context).size.width * (4 / 7),
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
                  '4/7',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Spacer(),

              // Frequency
              const Text(
                'How often will you workout?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${_currentSliderValue.round()}',
                        style: const TextStyle(
                          color: Color(0xFFCDFF00),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' Days',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Chip(
                  label: Text("Number of Days",
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Color(0xFF3A3A3C),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFCDFF00),
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.grey[600],
                  overlayColor: const Color(0xFFCDFF00).withValues(alpha: 0.2),
                  trackHeight: 4.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                ),
                child: Slider(
                  value: _currentSliderValue,
                  min: 1,
                  max: 7,
                  divisions: 6,
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('7', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),

              const Spacer(),

              // Duration
              const Text(
                'How much time do you have to workout?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: durations.map((d) => _buildDurationOption(d)).toList(),
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
                      widget.onboardingData.workoutDaysPerWeek =
                          _currentSliderValue.round();
                      widget.onboardingData.workoutDuration = selectedDuration;
                      print('[Onboarding] Step 4 — days: ${widget.onboardingData.workoutDaysPerWeek}, '
                          'duration: ${widget.onboardingData.workoutDuration}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainingLocationScreen(
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
