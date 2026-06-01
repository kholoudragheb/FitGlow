import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/meal_plan_model.dart';
import '../utils/token_storage.dart';

class AIMealService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<MealPlan> generateMealPlan({
    required String diet,
    required int targetCalories,
    required List<String> allergies,
    required int mealsPerDay,
  }) async {
    final url = Uri.parse('$baseUrl/ai/meal-plan');
    
    if (kDebugMode) {
      print("Generating meal plan...");
      print("Request: diet=$diet, calories=$targetCalories");
    }
    
    final token = await TokenStorage.getAccessToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'diet': diet,
          'targetCalories': targetCalories,
          'allergies': allergies,
          'mealsPerDay': mealsPerDay,
        }),
      );

      if (kDebugMode) {
        print("Response:");
        print(response.body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        final mealPlanResponse = MealPlanResponse.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
        
        if (mealPlanResponse.plan == null) {
          throw Exception('Received an invalid plan payload from the AI.');
        }

        final plan = mealPlanResponse.plan!;

        // Handle logical '503' error inside description payload!
        if (plan.description.contains('503 UNAVAILABLE')) {
          throw Exception("AI service is currently busy. Please try again in a moment.");
        }

        return plan;
      } else if (response.statusCode == 503) {
        throw Exception("AI service is currently busy. Please try again in a moment.");
      } else {
        throw Exception('Failed to generate plan. (Status \${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('AI service is currently busy')) {
        rethrow;
      }
      if (kDebugMode) {
        print("Network error generating meal plan: \$e");
      }
      throw Exception('Network error: Could not reach the server. Please check your connection.');
    }
  }
}
