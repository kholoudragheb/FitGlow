import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../logic/cubits/nutrition/meal_detail_cubit.dart';
import '../../../models/meal_model.dart';
import '../../../services/nutrition_service.dart';

class MealDetailScreen extends StatelessWidget {
  final String mealId;

  const MealDetailScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MealDetailCubit(NutritionService(), mealId)..fetchMealDetails(),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: BlocBuilder<MealDetailCubit, MealDetailState>(
          builder: (context, state) {
            if (state is MealDetailLoading) {
              return _buildShimmerLoading();
            } else if (state is MealDetailError) {
              return _buildErrorState(state.message, context);
            } else if (state is MealDetailSuccess) {
              return _buildContent(context, state.meal);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MealModel meal) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, meal),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(meal),
                const SizedBox(height: 24),
                _buildNutritionGrid(meal),
                const SizedBox(height: 32),
                _buildSectionTitle("Description"),
                const SizedBox(height: 12),
                Text(
                  meal.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Ingredients"),
                const SizedBox(height: 16),
                ...meal.ingredients.map((ing) => _buildIngredientItem(ing)),
                const SizedBox(height: 32),
                _buildSectionTitle("Preparation Steps"),
                const SizedBox(height: 16),
                ...meal.preparationSteps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, MealModel meal) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: const Color(0xFF1E1E1E),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            meal.image.isNotEmpty
                ? Image.network(meal.image, fit: BoxFit.cover)
                : Container(color: Colors.grey[900]),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF111111).withValues(alpha: 0.8),
                    const Color(0xFF111111),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(MealModel meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD0FD3E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD0FD3E).withValues(alpha: 0.5)),
              ),
              child: Text(
                meal.mealType.toUpperCase(),
                style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            ...meal.tags.take(2).map((tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text("#$tag", style: const TextStyle(color: Colors.white38, fontSize: 12)),
            )),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          meal.name,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildNutritionGrid(MealModel meal) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.8,
      children: [
        _buildNutritionCard("Calories", "${meal.calories}", "kcal"),
        _buildNutritionCard("Protein", "${meal.protein}", "g"),
        _buildNutritionCard("Carbs", "${meal.carbs}", "g"),
        _buildNutritionCard("Fats", "${meal.fats}", "g"),
      ],
    );
  }

  Widget _buildNutritionCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(unit, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildIngredientItem(IngredientModel ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFFD0FD3E)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.name,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Text(
            "${ingredient.quantity} ${ingredient.unit}",
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(color: Color(0xFFD0FD3E), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              "$stepNumber",
              style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              step,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 350, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 30, width: 200, color: Colors.white),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (_) => Container(height: 80, width: 70, color: Colors.white)),
                  ),
                  const SizedBox(height: 32),
                  Container(height: 100, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<MealDetailCubit>().fetchMealDetails(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
            child: const Text("Retry", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
