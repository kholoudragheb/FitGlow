import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/fitness_plan_model.dart';
import '../utils/token_storage.dart';

class AIPlanService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<FitnessPlanResponse> generateFitnessPlan(FitnessPlanRequest request) async {
    final url = Uri.parse('$baseUrl/ai/plan');
    
    if (kDebugMode) {
      print("Generating fitness plan for user: \${request.userData.userId}");
      print("Payload: \${jsonEncode(request.toJson())}");
    }
    
    final token = await TokenStorage.getAccessToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (kDebugMode) {
        print("Received response: \${response.statusCode} - \${response.body}");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return FitnessPlanResponse.fromJson(data);
      } else if (response.statusCode == 503) {
        throw Exception('Service is currently facing high demand. Please try again in a few moments.');
      } else {
        throw Exception('Failed to generate plan. Server responded with Status \${response.statusCode}.');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in generating plan: \$e");
      }
      if (e is Exception && e.toString().contains('Service is currently facing high demand')) {
        rethrow;
      }
      throw Exception('Network error: Could not reach the server. Please check your connection.');
    }
  }
}
