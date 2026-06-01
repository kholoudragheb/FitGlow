import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../logic/cubits/nutrition/nutrition_cubit.dart';
import '../../../models/meal_model.dart';
import 'MealDetailScreen.dart';

class NutritionLibraryScreen extends StatefulWidget {
  const NutritionLibraryScreen({super.key});

  @override
  State<NutritionLibraryScreen> createState() => _NutritionLibraryScreenState();
}

class _NutritionLibraryScreenState extends State<NutritionLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTag;
  String? _selectedMealType;
  Timer? _debounce;

  final List<String> _tags = ['High Protein', 'Vegan', 'Keto', 'Low Carb', 'Healthy', 'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Omega-3', 'Post-Workout'];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  void _fetchMeals() {
    context.read<NutritionCubit>().fetchMeals(
      tags: _selectedTag,
      search: _searchController.text,
      mealType: _selectedMealType,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          "Nutrition Library",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchMeals(),
              color: const Color(0xFFD0FD3E),
              backgroundColor: const Color(0xFF1E1E1E),
              child: BlocBuilder<NutritionCubit, NutritionState>(
                builder: (context, state) {
                  if (state is NutritionLoading) {
                    return _buildShimmerLoading();
                  } else if (state is NutritionError) {
                    return _buildErrorState(state.message);
                  } else if (state is NutritionSuccess) {
                    if (state.meals.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildMealsList(state.meals);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search meals...",
            hintStyle: TextStyle(color: Colors.white38),
            prefixIcon: Icon(Icons.search, color: Colors.white38),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip("All Types", _selectedMealType == null, () {
                setState(() => _selectedMealType = null);
                _fetchMeals();
              }),
              ..._mealTypes.map((t) => _buildFilterChip(
                t.toUpperCase(),
                _selectedMealType == t,
                () {
                  setState(() => _selectedMealType = t);
                  _fetchMeals();
                },
              )),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTagChip("Any Tag", _selectedTag == null, () {
                setState(() => _selectedTag = null);
                _fetchMeals();
              }),
              ..._tags.map((t) => _buildTagChip(
                t,
                _selectedTag == t,
                () {
                  setState(() => _selectedTag = t);
                  _fetchMeals();
                },
              )),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: const Color(0xFFD0FD3E),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        checkmarkColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD0FD3E).withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFD0FD3E) : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFD0FD3E) : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealsList(List<MealModel> meals) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meals.length,
      itemBuilder: (context, index) => _buildMealCard(meals[index]),
    );
  }

  Widget _buildMealCard(MealModel meal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(mealId: meal.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: meal.image.isNotEmpty 
                          ? NetworkImage(meal.image) 
                          : const AssetImage('lib/assets/images/nutrition/nutrition_yogurt_1.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        meal.mealType.toUpperCase(),
                        style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMacroInfo("Calories", "${meal.calories} kcal"),
                        _buildMacroInfo("Protein", "${meal.protein}g"),
                        _buildMacroInfo("Carbs", "${meal.carbs}g"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: meal.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("#$tag", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text("No meals found", style: TextStyle(color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTag = null;
                _selectedMealType = null;
                _searchController.clear();
              });
              _fetchMeals();
            },
            child: const Text("Clear Filters", style: TextStyle(color: Color(0xFFD0FD3E))),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchMeals,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
            child: const Text("Retry", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
