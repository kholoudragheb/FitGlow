class WorkoutPlan {
  final String name;
  final int daysPerWeek;
  final String description;

  WorkoutPlan({
    required this.name,
    required this.daysPerWeek,
    required this.description,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      name: json['name'] ?? 'Custom Workout Plan',
      daysPerWeek: json['days_per_week'] as int? ?? 3,
      description: json['description'] ?? '',
    );
  }
}

class WorkoutPlanResponse {
  final WorkoutPlan? plan;
  final String userId;

  WorkoutPlanResponse({this.plan, required this.userId});

  factory WorkoutPlanResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanResponse(
      plan: json['plan'] != null ? WorkoutPlan.fromJson(json['plan']) : null,
      userId: json['user_id'] ?? '',
    );
  }
}
