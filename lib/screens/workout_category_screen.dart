import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants.dart';
import '../models/workout_models.dart';
import 'workout_exercises_screen.dart';
import 'workout_search_screen.dart';

class WorkoutCategoryScreen extends StatefulWidget {
  final WorkoutCategory category;

  const WorkoutCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<WorkoutCategoryScreen> createState() => _WorkoutCategoryScreenState();
}

class _WorkoutCategoryScreenState extends State<WorkoutCategoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Full Body', 'Upper Body', 'Lower Body', 'Abs'];

  // Mock workout data with real Figma images
  final List<Workout> _workouts = [
    Workout(
      id: '1',
      title: 'Belly fat burner HIIT',
      categoryId: 'strength',
      level: 'Beginner',
      durationMinutes: 10,
      thumbnailImage: 'lib/assets/images/workout/exercise_1.png',
      subcategories: ['Full Body'],
    ),
    Workout(
      id: '2',
      title: 'Belly fat burner HIIT',
      categoryId: 'strength',
      level: 'Intermediate',
      durationMinutes: 10,
      thumbnailImage: 'lib/assets/images/workout/exercise_2.png',
      subcategories: ['Full Body'],
    ),
    Workout(
      id: '3',
      title: 'Belly fat burner HIIT',
      categoryId: 'strength',
      level: 'Advanced',
      durationMinutes: 10,
      thumbnailImage: 'lib/assets/images/workout/exercise_3.png',
      subcategories: ['Upper Body'],
    ),
    Workout(
      id: '4',
      title: 'Belly fat burner HIIT',
      categoryId: 'strength',
      level: 'Beginner',
      durationMinutes: 10,
      thumbnailImage: 'lib/assets/images/workout/exercise_4.png',
      subcategories: ['Lower Body'],
    ),
    Workout(
      id: '5',
      title: 'Belly fat burner HIIT',
      categoryId: 'strength',
      level: 'Advanced',
      durationMinutes: 10,
      thumbnailImage: 'lib/assets/images/workout/exercise_5.png',
      subcategories: ['Abs'],
    ),
    Workout(
      id: '6',
      title: 'Belly fat burner HIIT',
      categoryId: 'strength',
      level: 'Beginner',
      durationMinutes: 10,
      thumbnailImage: 'lib/assets/images/workout/exercise_6.png',
      subcategories: ['Full Body'],
    ),
  ];

  List<Workout> get _filteredWorkouts {
    if (_selectedFilter == 'All') return _workouts;
    return _workouts.where((w) => w.subcategories.contains(_selectedFilter)).toList();
  }

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
            const SizedBox(height: 16),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WorkoutSearchScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppConstants.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AppConstants.iconSearch,
                              colorFilter: const ColorFilter.mode(
                                AppConstants.textSecondary,
                                BlendMode.srcIn,
                              ),
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Search workout...',
                              style: AppConstants.bodyMedium.copyWith(
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        AppConstants.iconFilter,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppConstants.primaryColor : Colors.grey.shade600,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Workout List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredWorkouts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final workout = _filteredWorkouts[index];
                  return _buildWorkoutCard(workout);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutExercisesScreen(workout: workout),
          ),
        );
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                workout.thumbnailImage,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      workout.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getLevelColor(workout.level),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          workout.level,
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          color: AppConstants.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.durationMinutes} min',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
