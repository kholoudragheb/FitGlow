class UserData {
  final int age;
  final int weight;
  final int height;
  final String fitnessLevel;
  final List<String> goals;
  final String userId;

  UserData({
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessLevel,
    required this.goals,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'weight': weight,
      'height': height,
      'fitnessLevel': fitnessLevel,
      'goals': goals,
      'userId': userId,
    };
  }
}

class FitnessPlanRequest {
  final UserData userData;

  FitnessPlanRequest({required this.userData});

  Map<String, dynamic> toJson() {
    return {
      'userData': userData.toJson(),
    };
  }
}

class PlanDetails {
  final String planName;
  final String goal;
  final int durationWeeks;
  final String description;

  PlanDetails({
    required this.planName,
    required this.goal,
    required this.durationWeeks,
    required this.description,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) {
    return PlanDetails(
      planName: json['plan_name'] ?? 'Custom Plan',
      goal: json['goal'] ?? '',
      durationWeeks: json['duration_weeks'] as int? ?? 4,
      description: json['description'] ?? '',
    );
  }
}

class FitnessPlanResponse {
  final PlanDetails? plan;
  final String userId;

  FitnessPlanResponse({this.plan, required this.userId});

  factory FitnessPlanResponse.fromJson(Map<String, dynamic> json) {
    return FitnessPlanResponse(
      plan: json['plan'] != null ? PlanDetails.fromJson(json['plan']) : null,
      userId: json['user_id'] ?? '',
    );
  }
}
