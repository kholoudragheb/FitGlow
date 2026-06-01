class UserModel {
  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final List<String> healthConditions;
  final List<String> preferredTrainingDays;
  final List<String> dietaryPreferences;
  final bool onboardingCompleted;
  final List<String> savedWorkouts;
  final List<String> savedMeals;
  final bool isVerified;
  final bool emailNotifications;
  final bool pushNotifications;
  final List<String> fcmTokens;
  final bool isBanned;
  final String subscriptionStatus;
  final String? createdAt;
  final String? updatedAt;
  final String? lastLoginAt;
  final String? otpExpiry;
  final String? fitnessGoal;
  final String? fitnessLevel;
  final String? gender;
  final num? height;
  final num? weight;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.healthConditions,
    required this.preferredTrainingDays,
    required this.dietaryPreferences,
    required this.onboardingCompleted,
    required this.savedWorkouts,
    required this.savedMeals,
    required this.isVerified,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.fcmTokens,
    required this.isBanned,
    required this.subscriptionStatus,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.otpExpiry,
    this.fitnessGoal,
    this.fitnessLevel,
    this.gender,
    this.height,
    this.weight,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      preferredTrainingDays: List<String>.from(json['preferredTrainingDays'] ?? []),
      dietaryPreferences: List<String>.from(json['dietaryPreferences'] ?? []),
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      savedWorkouts: List<String>.from(json['savedWorkouts'] ?? []),
      savedMeals: List<String>.from(json['savedMeals'] ?? []),
      isVerified: json['isVerified'] ?? false,
      emailNotifications: json['emailNotifications'] ?? false,
      pushNotifications: json['pushNotifications'] ?? false,
      fcmTokens: List<String>.from(json['fcmTokens'] ?? []),
      isBanned: json['isBanned'] ?? false,
      subscriptionStatus: json['subscriptionStatus'] ?? 'none',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      lastLoginAt: json['lastLoginAt'],
      otpExpiry: json['otpExpiry'],
      fitnessGoal: json['fitnessGoal'],
      fitnessLevel: json['fitnessLevel'],
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'healthConditions': healthConditions,
      'preferredTrainingDays': preferredTrainingDays,
      'dietaryPreferences': dietaryPreferences,
      'onboardingCompleted': onboardingCompleted,
      'savedWorkouts': savedWorkouts,
      'savedMeals': savedMeals,
      'isVerified': isVerified,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'fcmTokens': fcmTokens,
      'isBanned': isBanned,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
      'otpExpiry': otpExpiry,
      'fitnessGoal': fitnessGoal,
      'fitnessLevel': fitnessLevel,
      'gender': gender,
      'height': height,
      'weight': weight,
    };
  }
}
