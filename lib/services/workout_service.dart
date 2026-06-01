import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/workout_model.dart';
import '../utils/token_storage.dart';

class WorkoutService {
  final String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  final Duration _timeout = const Duration(seconds: 15);

  Future<List<WorkoutModel>> getAllWorkouts({
    String? difficulty,
    String? tags,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (difficulty != null && difficulty.isNotEmpty) queryParams['difficulty'] = difficulty;
    if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/workouts').replace(queryParameters: queryParams);
    return _fetchWorkouts(uri);
  }

  Future<WorkoutModel> getWorkoutById({
    required String workoutId,
  }) async {
    final uri = Uri.parse('$baseUrl/workouts/$workoutId');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching workout details...");
      print("ID: $workoutId");
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
        print("Workout Details Status: ${response.statusCode}");
        print("Workout Details Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final workoutData = (data is Map) ? (data['workout'] ?? data['data'] ?? data) : data;
        return WorkoutModel.fromJson(workoutData);
      } else if (response.statusCode == 404) {
        throw Exception('Workout not found.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      debugPrint('[WorkoutService] Error fetching details: $e');
      rethrow;
    }
  }

  Future<List<WorkoutModel>> _fetchWorkouts(Uri uri) async {
    final token = await TokenStorage.getAccessToken();
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Workouts Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List workoutsData = (data is List) 
            ? data 
            : (data is Map ? (data['workouts'] ?? data['data'] ?? []) : []);
        return workoutsData.map((w) => WorkoutModel.fromJson(w)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }
}
