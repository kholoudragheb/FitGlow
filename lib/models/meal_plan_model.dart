class MealPlan {
  final String name;
  final String goal;
  final int mealsPerDay;
  final String description;

  MealPlan({
    required this.name,
    required this.goal,
    required this.mealsPerDay,
    required this.description,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      name: json['name'] ?? 'Custom Meal Plan',
      goal: json['goal'] ?? '',
      mealsPerDay: json['meals_per_day'] as int? ?? 1,
      description: json['description'] ?? '',
    );
  }
}

class MealPlanResponse {
  final MealPlan? plan;
  final String userId;

  MealPlanResponse({this.plan, required this.userId});

  factory MealPlanResponse.fromJson(Map<String, dynamic> json) {
    return MealPlanResponse(
      plan: json['plan'] != null ? MealPlan.fromJson(json['plan']) : null,
      userId: json['user_id'] ?? '',
    );
  }
}
