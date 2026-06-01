class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final num? height;
  final num? weight;
  final String? fitnessGoal;
  final String? fitnessLevel;
  final String? gender;
  final bool? onboardingCompleted;
  final List<String>? dietaryPreferences;
  final List<String>? healthConditions;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.fitnessLevel,
    this.gender,
    this.onboardingCompleted,
    this.dietaryPreferences,
    this.healthConditions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (fitnessGoal != null) data['fitnessGoal'] = fitnessGoal;
    if (fitnessLevel != null) data['fitnessLevel'] = fitnessLevel;
    if (gender != null) data['gender'] = gender;
    if (onboardingCompleted != null) data['onboardingCompleted'] = onboardingCompleted;
    if (dietaryPreferences != null) data['dietaryPreferences'] = dietaryPreferences;
    if (healthConditions != null) data['healthConditions'] = healthConditions;
    return data;
  }
}

class UpdateProfileResponse {
  final bool isSuccess;
  final String? message;
  final int statusCode;

  UpdateProfileResponse({
    required this.isSuccess,
    this.message,
    required this.statusCode,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    return UpdateProfileResponse(
      isSuccess: statusCode >= 200 && statusCode < 300,
      message: json['message'],
      statusCode: statusCode,
    );
  }

  factory UpdateProfileResponse.withError(String message, {int statusCode = 500}) {
    return UpdateProfileResponse(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
