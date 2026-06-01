import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/core/constants.dart';
import '../models/workout_plan_model.dart';
import '../services/ai_workout_service.dart';

class AIWorkoutPlanScreen extends StatefulWidget {
  final String fitnessLevel;
  final List<String> goals;
  final int duration;
  final List<String> equipment;
  final List<String> targetMuscles;

  const AIWorkoutPlanScreen({
    super.key,
    required this.fitnessLevel,
    required this.goals,
    required this.duration,
    required this.equipment,
    required this.targetMuscles,
  });

  @override
  State<AIWorkoutPlanScreen> createState() => _AIWorkoutPlanScreenState();
}

class _AIWorkoutPlanScreenState extends State<AIWorkoutPlanScreen> {
  final AIWorkoutService _workoutService = AIWorkoutService();
  bool _isLoading = true;
  String? _errorMessage;
  WorkoutPlan? _workoutPlan;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutPlan();
  }

  Future<void> _fetchWorkoutPlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plan = await _workoutService.generateWorkoutPlan(
        fitnessLevel: widget.fitnessLevel,
        goals: widget.goals,
        duration: widget.duration,
        equipment: widget.equipment,
        targetMuscles: widget.targetMuscles,
      );

      if (mounted) {
        setState(() {
          _workoutPlan = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppConstants.iconBack,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your AI Workout Plan",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFFF0F0F0),
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
            SizedBox(height: 24),
            Text(
              "Building your custom workout routine...",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Color(0xFFF0F0F0),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, color: Colors.orangeAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Loading Error",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF72777A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _fetchWorkoutPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    if (_workoutPlan != null) {
      final plan = _workoutPlan!;
      return RefreshIndicator(
        onRefresh: _fetchWorkoutPlan,
        color: AppConstants.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Frequency: \${plan.daysPerWeek} Days / Week",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Duration: \${widget.duration} Mins / Session",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Workout Routine",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  plan.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFFE0E0E0),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Save Workout Plan",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
