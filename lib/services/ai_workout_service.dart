import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/workout_plan_model.dart';
import '../utils/token_storage.dart';

class AIWorkoutService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<WorkoutPlan> generateWorkoutPlan({
    required String fitnessLevel,
    required List<String> goals,
    required int duration,
    required List<String> equipment,
    required List<String> targetMuscles,
  }) async {
    final url = Uri.parse('$baseUrl/ai/workout-plan');
    
    if (kDebugMode) {
      print("Generating workout plan...");
      print("Goals: $goals");
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
          'fitnessLevel': fitnessLevel,
          'goals': goals,
          'duration': duration,
          'equipment': equipment,
          'targetMuscles': targetMuscles,
        }),
      );

      if (kDebugMode) {
        print("Response:");
        print(response.body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        final workoutPlanResponse = WorkoutPlanResponse.fromJson(data is Map<String, dynamic> ? data : <String, dynamic>{});
        
        if (workoutPlanResponse.plan == null) {
          throw Exception('Received an invalid plan payload from the AI.');
        }

        final plan = workoutPlanResponse.plan!;

        // Trap 503 errors embedded inside the text response
        if (plan.description.contains('503 UNAVAILABLE')) {
          throw Exception("AI service is currently busy. Please try again shortly.");
        }

        return plan;
      } else if (response.statusCode == 503) {
        throw Exception("AI service is currently busy. Please try again shortly.");
      } else {
        throw Exception('Failed to generate plan. (Status \${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('AI service is currently busy')) {
        rethrow;
      }
      if (kDebugMode) {
        print("Network error generating workout plan: \$e");
      }
      throw Exception('Network error: Could not reach the server. Please check your connection or inputs.');
    }
  }
}
