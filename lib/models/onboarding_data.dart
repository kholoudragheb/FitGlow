/// Mutable container that accumulates data across all onboarding screens.
/// Passed forward through Navigator arguments so that step 7 can submit
/// everything in a single PUT /users/me call.
class OnboardingData {
  // Step 1 — Build Your Profile
  String? gender;
  String? dateOfBirth;
  int? weightKg;        // numeric, kg
  int? heightCm;        // numeric, cm

  // Step 2 — Build Goal
  String? fitnessGoal;  // e.g. "Lose Weight", "Gain Muscle", "Stay Fit"

  // Step 3 — Experience Level
  String? fitnessLevel; // "Beginner" | "Intermediate" | "Advanced"

  // Step 4 — Workout Frequency
  int? workoutDaysPerWeek;
  String? workoutDuration; // e.g. "30 min"

  // Step 5 — Training Location
  String? trainingLocation;
  List<String> equipment = [];

  // Step 6 — Health & Limits
  bool hasInjuries = false;
  String? injuriesDescription;
  bool hasChronicConditions = false;
  String? chronicConditionsDescription;
  List<String> healthConditions = [];

  // Step 7 — Nutrition Preferences
  String? eatingStyle;   // "Normal" | "Vegetarian" | "Vegan" | "Keto"
  List<String> allergies = [];

  OnboardingData();

  /// Maps fitness goal label to the value the backend expects.
  /// UPDATE: Returning original label as per backend example requirements.
  static String mapFitnessGoal(String? label) {
    return label ?? 'Stay Fit';
  }

  /// Maps fitness level label to backend value.
  /// UPDATE: Returning original label as per backend example requirements.
  static String mapFitnessLevel(String? label) {
    return label ?? 'Beginner';
  }

  /// Builds the list of health conditions from injury/chronic answers.
  List<String> buildHealthConditions() {
    final conditions = <String>[];
    if (hasInjuries && injuriesDescription != null && injuriesDescription!.trim().isNotEmpty) {
      conditions.add('Injury: ${injuriesDescription!.trim()}');
    }
    if (hasChronicConditions && chronicConditionsDescription != null && chronicConditionsDescription!.trim().isNotEmpty) {
      conditions.add('Chronic: ${chronicConditionsDescription!.trim()}');
    }
    return conditions;
  }

  /// Builds dietary preferences from eating style + allergies.
  List<String> buildDietaryPreferences() {
    final prefs = <String>[];
    if (eatingStyle != null && eatingStyle!.isNotEmpty) {
      prefs.add(eatingStyle!);
    }
    for (final a in allergies) {
      prefs.add('Allergy: $a');
    }
    return prefs;
  }
}
