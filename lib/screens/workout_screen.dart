import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants.dart';
import '../models/workout_models.dart';
import 'workout_search_screen.dart';
import 'workout_filter_screen.dart';
import 'workout_category_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  // Category data with real Figma images
  static const List<WorkoutCategory> _categories = [
    WorkoutCategory(
      id: 'strength',
      name: 'Strength',
      image: 'lib/assets/images/workout/category_strength.png',
      workoutCount: 24,
    ),
    WorkoutCategory(
      id: 'cardio',
      name: 'Cardio',
      image: 'lib/assets/images/workout/category_cardio.png',
      workoutCount: 18,
    ),
    WorkoutCategory(
      id: 'yoga',
      name: 'Yoga',
      image: 'lib/assets/images/workout/category_yoga.png',
      workoutCount: 15,
    ),
    WorkoutCategory(
      id: 'stretching',
      name: 'Stretching',
      image: 'lib/assets/images/workout/category_stretching.png',
      workoutCount: 12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Workout',
                style: AppConstants.headlineLarge,
              ),
              
              const SizedBox(height: 20),
              
              // Search Bar with Filter Button
              Row(
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkoutFilterScreen(),
                        ),
                      );
                    },
                    child: Container(
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
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Category Cards
              Expanded(
                child: ListView.separated(
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(context, _categories[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, WorkoutCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutCategoryScreen(category: category),
          ),
        );
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(category.image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              category.name,
              style: AppConstants.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
