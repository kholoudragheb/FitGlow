import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants.dart';

class WorkoutFilterScreen extends StatefulWidget {
  const WorkoutFilterScreen({super.key});

  @override
  State<WorkoutFilterScreen> createState() => _WorkoutFilterScreenState();
}

class _WorkoutFilterScreenState extends State<WorkoutFilterScreen> {
  // Categories
  final Set<String> _selectedCategories = {};
  final List<String> _categories = ['Strength', 'Cardio', 'Yoga', 'Stretching'];
  
  // Subcategories
  final Set<String> _selectedSubcategories = {};
  final List<String> _subcategories = [
    'Full Body',
    'Upper Body',
    'Lower Body',
    'Abs & Core',
    'Back',
    'Arm',
    'Chest',
    'Legs',
    'Muscles',
  ];
  
  // Levels
  String? _selectedLevel;
  final List<String> _levels = ['Beginner', 'intermediate', 'Advanced'];
  
  // Durations
  String? _selectedDuration;
  final List<String> _durations = ['5-10 min', '15-20 min', '30 min', '30+ min'];

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
              const SizedBox(height: 16),
              
              // Header
              Row(
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Filter',
                        style: TextStyle(
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
              
              const SizedBox(height: 32),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories Section
                      _buildSectionTitle('Categories'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return _buildChip(
                            label: category,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedCategories.remove(category);
                                } else {
                                  _selectedCategories.add(category);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Subcategories Section
                      _buildSectionTitle('Subcategories'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _subcategories.map((subcategory) {
                          final isSelected = _selectedSubcategories.contains(subcategory);
                          return _buildChip(
                            label: subcategory,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSubcategories.remove(subcategory);
                                } else {
                                  _selectedSubcategories.add(subcategory);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Level Section
                      _buildSectionTitle('Level'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _levels.map((level) {
                          final isSelected = _selectedLevel == level;
                          return _buildChip(
                            label: level,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedLevel = isSelected ? null : level;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Duration Section
                      _buildSectionTitle('Duration'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _durations.map((duration) {
                          final isSelected = _selectedDuration == duration;
                          return _buildChip(
                            label: duration,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedDuration = isSelected ? null : duration;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Apply Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters and go back
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: AppConstants.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
