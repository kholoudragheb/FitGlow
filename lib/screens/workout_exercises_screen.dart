import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants.dart';
import '../models/workout_models.dart';
import '../services/user_service.dart';
import 'exercise_player_screen.dart';

class WorkoutExercisesScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutExercisesScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutExercisesScreen> createState() => _WorkoutExercisesScreenState();
}

class _WorkoutExercisesScreenState extends State<WorkoutExercisesScreen> {
  bool _isSaved = false;
  bool _isSaving = false;
  final UserService _userService = UserService();

  Future<void> _toggleSaveWorkout() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isSaved) {
        await _userService.unsaveWorkout(widget.workout.id);
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout removed from saved')),
          );
        }
      } else {
        await _userService.saveWorkout(widget.workout.id);
        if (mounted) {
          setState(() {
            _isSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout saved')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('401')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
        } else if (e.toString().toLowerCase().contains('already saved') || e.toString().contains('409')) {
          setState(() {
            _isSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout already saved')),
          );
        } else if (e.toString().toLowerCase().contains('not found') || e.toString().contains('404')) {
          setState(() {
            _isSaved = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout not found in saved list')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update workout status: $e')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Mock exercise data with real Figma images
  static final List<Exercise> _mockExercises = [
    Exercise(
      id: '1',
      name: 'Jumping Jacks',
      subtitle: 'Jumping Jacks',
      durationSeconds: 50,
      thumbnailImage: 'lib/assets/images/workout/exercise_1.png',
      howToSteps: [
        'Stand with your feet together and arms at your sides',
        'Jump while spreading legs and raising arms overhead',
        'Return to starting position and repeat',
      ],
      keyTips: [
        'Keep your core engaged throughout',
        'Land softly on the balls of your feet',
        'Maintain a steady rhythm',
      ],
    ),
    Exercise(
      id: '2',
      name: 'Jumping Jacks',
      subtitle: '',
      durationSeconds: 50,
      thumbnailImage: 'lib/assets/images/workout/exercise_2.png',
    ),
    Exercise(
      id: '3',
      name: 'Jumping Jacks',
      subtitle: '',
      durationSeconds: 50,
      thumbnailImage: 'lib/assets/images/workout/exercise_3.png',
    ),
    Exercise(
      id: '4',
      name: 'Jumping Jacks',
      subtitle: '',
      durationSeconds: 50,
      thumbnailImage: 'lib/assets/images/workout/exercise_4.png',
    ),
    Exercise(
      id: '5',
      name: 'Jumping Jacks',
      subtitle: '',
      durationSeconds: 50,
      thumbnailImage: 'lib/assets/images/workout/exercise_5.png',
    ),
    Exercise(
      id: '6',
      name: 'Jumping Jacks',
      subtitle: '',
      durationSeconds: 50,
      thumbnailImage: 'lib/assets/images/workout/exercise_6.png',
    ),
    Exercise(
      id: '7',
      name: 'Jumping Jacks',
      subtitle: '',
      durationSeconds: 50,
      thumbnailImage: 'lib/assets/images/workout/exercise_7.png',
    ),
  ];

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppConstants.primaryColor;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return AppConstants.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              AppConstants.iconBack,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleSaveWorkout,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade700),
                            borderRadius: BorderRadius.circular(12),
                            color: _isSaved ? AppConstants.primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                          ),
                          child: Center(
                            child: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    _isSaved ? 'lib/assets/images/profile/ic_saved.svg' : AppConstants.iconBookmark,
                                    colorFilter: ColorFilter.mode(
                                      _isSaved ? AppConstants.primaryColor : Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                    width: 22,
                                    height: 22,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Workout Title
                  Text(
                    'Abs Exercises',
                    style: AppConstants.headlineMedium,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Level and Duration
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getLevelColor(widget.workout.level),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.workout.level,
                        style: TextStyle(
                          color: AppConstants.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        color: AppConstants.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.workout.durationMinutes} min',
                        style: TextStyle(
                          color: AppConstants.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Exercise Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${_mockExercises.length} Exercises',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Exercise List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _mockExercises.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exercise = _mockExercises[index];
                  return _buildExerciseCard(context, exercise, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExercisePlayerScreen(
              exercise: exercise,
              currentIndex: index,
              totalExercises: _mockExercises.length,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                exercise.thumbnailImage,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (exercise.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      exercise.subtitle,
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    exercise.formattedDuration,
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
