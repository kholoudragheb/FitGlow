class IngredientModel {
  final String name;
  final String quantity;
  final String unit;

  IngredientModel({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'] ?? '',
      quantity: json['quantity']?.toString() ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class MealModel {
  final String id;
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final int fiber;
  final int sugar;
  final int sodium;
  final String image;
  final List<IngredientModel> ingredients;
  final List<String> preparationSteps;
  final List<String> tags;
  final String mealType;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    required this.image,
    required this.ingredients,
    required this.preparationSteps,
    required this.tags,
    required this.mealType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final description = json['content'] ?? json['description'] ?? '';
    
    // Parse ingredients and steps from markdown content if missing
    List<IngredientModel> ingredients = (json['ingredients'] as List? ?? [])
        .map((e) => e is String 
            ? IngredientModel(name: e, quantity: '', unit: '') 
            : IngredientModel.fromJson(e))
        .toList();
        
    List<String> steps = List<String>.from(json['preparationSteps'] ?? []);

    if (ingredients.isEmpty && description.isNotEmpty) {
      ingredients = _parseIngredientsFromContent(description);
    }
    
    if (steps.isEmpty && description.isNotEmpty) {
      steps = _parseStepsFromContent(description);
    }

    return MealModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['title'] ?? json['name'] ?? '',
      description: description,
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
      fiber: json['fiber'] ?? 0,
      sugar: json['sugar'] ?? 0,
      sodium: json['sodium'] ?? 0,
      image: json['imageUrl'] ?? json['image'] ?? '',
      ingredients: ingredients,
      preparationSteps: steps,
      tags: List<String>.from(json['tags'] ?? []),
      mealType: json['mealType'] ?? 'Snack',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static List<IngredientModel> _parseIngredientsFromContent(String content) {
    final ingredients = <IngredientModel>[];
    try {
      final lines = content.split('\n');
      bool inSection = false;
      for (var line in lines) {
        if (line.toLowerCase().contains('ingredients')) {
          inSection = true;
          continue;
        }
        if (inSection && line.startsWith('##')) break;
        if (inSection && line.trim().isNotEmpty) {
          final items = line.split(',');
          for (var item in items) {
            final name = item.replaceAll(RegExp(r'^[-*•\s]+'), '').trim();
            if (name.isNotEmpty) {
              ingredients.add(IngredientModel(name: name, quantity: '', unit: ''));
            }
          }
        }
      }
    } catch (_) {}
    return ingredients;
  }

  static List<String> _parseStepsFromContent(String content) {
    final steps = <String>[];
    try {
      final lines = content.split('\n');
      bool inSection = false;
      for (var line in lines) {
        if (line.toLowerCase().contains('instructions') || line.toLowerCase().contains('preparation')) {
          inSection = true;
          continue;
        }
        if (inSection && line.startsWith('##')) break;
        if (inSection && line.trim().isNotEmpty) {
          final name = line.replaceAll(RegExp(r'^[-*•\s\d.] +'), '').trim();
          if (name.isNotEmpty) {
            steps.add(name);
          }
        }
      }
    } catch (_) {}
    return steps;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'image': image,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'preparationSteps': preparationSteps,
      'tags': tags,
      'mealType': mealType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
