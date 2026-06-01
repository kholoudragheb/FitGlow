import 'package:flutter/material.dart';
import 'package:fit_app/utils/nutrition_styles.dart';

class NutritionFilterScreen extends StatefulWidget {
  const NutritionFilterScreen({super.key});

  @override
  State<NutritionFilterScreen> createState() => _NutritionFilterScreenState();
}

class _NutritionFilterScreenState extends State<NutritionFilterScreen> {
  // Meals (multi-select)
  final List<String> _mealOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Salad', 'Soup'];
  final List<String> _selectedMeals = [];

  // Calories slider
  double _caloriesValue = 300;

  // Diet (multi-select)
  final List<String> _dietOptions = [
    'Vegetarian', 'Protein Rich', 'Low Carb',
    'Gluten Free', 'Vegan', 'Pescetarian',
    'Low Calories', 'Lactose Free', 'Sugar Free',
  ];
  final List<String> _selectedDiet = [];

  // Method (multi-select)
  final List<String> _methodOptions = ['Quick', 'Few Ingredients', 'Easy'];
  final List<String> _selectedMethod = [];

  // Ingredients (multi-select)
  final List<String> _ingredientOptions = [
    'Fish', 'Seafood', 'Nuts', 'Eggs', 'Dairy',
    'Beef', 'Chicken', 'Bread', 'Pasta', 'Rice',
    'Potatoes', 'Avocado', 'Salmon', 'Bacon',
    'Spinach',
  ];
  final List<String> _selectedIngredients = [];

  void _toggleSelection(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutritionColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: NutritionColors.cardBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF5C5C5C)),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, color: NutritionColors.textWhite, size: 16),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Filter',
                      style: NutritionTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 32), // Balance the back button
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Meals
                    _buildSectionTitle('Meals'),
                    _buildMultiSelectChips(_mealOptions, _selectedMeals),

                    const SizedBox(height: 24),

                    // Calories
                    _buildSectionTitle('Calories'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('100 Kcal', style: NutritionTextStyles.caption.copyWith(color: NutritionColors.textGrey)),
                        Text('600+ Kcal', style: NutritionTextStyles.caption.copyWith(color: NutritionColors.textGrey)),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: NutritionColors.primary,
                        inactiveTrackColor: const Color(0xFF3A3A3A),
                        thumbColor: Colors.white,
                        overlayColor: NutritionColors.primary.withValues(alpha: 0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        value: _caloriesValue,
                        min: 100,
                        max: 600,
                        onChanged: (value) => setState(() => _caloriesValue = value),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${_caloriesValue.round()} Kcal',
                        style: NutritionTextStyles.caption.copyWith(color: NutritionColors.textWhite),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Diet
                    _buildSectionTitle('Diet'),
                    _buildMultiSelectChips(_dietOptions, _selectedDiet),

                    const SizedBox(height: 24),

                    // Method
                    _buildSectionTitle('Method'),
                    _buildMultiSelectChips(_methodOptions, _selectedMethod),

                    const SizedBox(height: 24),

                    // Ingredients
                    _buildSectionTitle('Ingredients'),
                    _buildMultiSelectChips(_ingredientOptions, _selectedIngredients),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutritionColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
                    style: NutritionTextStyles.subTitle.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: NutritionTextStyles.subTitle.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMultiSelectChips(List<String> options, List<String> selectedList) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedList.contains(option);
        return GestureDetector(
          onTap: () => _toggleSelection(selectedList, option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? NutritionColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? NutritionColors.primary : const Color(0xFF5C5C5C),
              ),
            ),
            child: Text(
              option,
              style: NutritionTextStyles.caption.copyWith(
                color: isSelected ? Colors.black : NutritionColors.textWhite,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
