class SavedItemsModel {
  final List<dynamic> savedWorkouts;
  final List<dynamic> savedMeals;

  SavedItemsModel({
    required this.savedWorkouts,
    required this.savedMeals,
  });

  factory SavedItemsModel.fromJson(Map<String, dynamic> json) {
    return SavedItemsModel(
      savedWorkouts: json['savedWorkouts'] ?? [],
      savedMeals: json['savedMeals'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'savedWorkouts': savedWorkouts,
      'savedMeals': savedMeals,
    };
  }
}
