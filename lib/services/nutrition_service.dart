import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../utils/token_storage.dart';

class NutritionService {
  final String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  final Duration _timeout = const Duration(seconds: 15);

  Future<List<MealModel>> getAllMeals({
    String? tags,
    String? search,
    String? mealType,
  }) async {
    final queryParams = <String, String>{};
    if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (mealType != null && mealType.isNotEmpty) queryParams['mealType'] = mealType;

    final uri = Uri.parse('$baseUrl/nutrition').replace(queryParameters: queryParams);
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching meals...");
      print("URL: $uri");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Meals Status: ${response.statusCode}");
        print("Meals Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List mealsData = (data is List) 
            ? data 
            : (data is Map ? (data['meals'] ?? data['data'] ?? []) : []);
        return mealsData.map((m) => MealModel.fromJson(m)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      debugPrint('[NutritionService] Error: $e');
      rethrow;
    }
  }

  Future<MealModel> getMealById(String mealId) async {
    final uri = Uri.parse('$baseUrl/nutrition/$mealId');
    final token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final mealData = (data is Map) ? (data['meal'] ?? data['data'] ?? data) : data;
        return MealModel.fromJson(mealData);
      } else {
        throw Exception('Meal not found.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
