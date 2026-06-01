import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/plan_model.dart';
import '../utils/token_storage.dart';

class PlanService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<PlanModel> createPlan(PlanCreateRequest request) async {
    final uri = Uri.parse('$baseUrl/plans');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Creating plan...");
      print("Payload: ${jsonEncode(request.toJson())}");
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PlanModel.fromJson(data);
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Validation failed. Please check your input.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden. You do not have permission to create plans.');
      } else if (response.statusCode == 404) {
        throw Exception('Client not found.');
      } else if (response.statusCode == 409) {
        throw Exception('Conflict. A similar plan might already exist.');
      } else {
        throw Exception('Server error (${response.statusCode}). Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) print("Error in createPlan: $e");
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<List<PlanModel>> getClientPlans(String clientId) async {
    final uri = Uri.parse('$baseUrl/plans').replace(queryParameters: {'clientId': clientId});
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PlanModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getClientPlans: $e");
      rethrow;
    }
  }

  Future<PlanModel> getPlanById(String planId) async {
    final uri = Uri.parse('$baseUrl/plans/$planId');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PlanModel.fromJson(data);
      } else {
        throw Exception('Failed to load plan: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getPlanById: $e");
      rethrow;
    }
  }

  Future<PlanModel> updatePlan({
    required String planId,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl/plans/$planId');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Updating plan: $planId");
      print("Payload: ${jsonEncode(body)}");
    }

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PlanModel.fromJson(data);
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Validation failed. Please check your input.');
      } else if (response.statusCode == 404) {
        throw Exception('Plan not found.');
      } else {
        throw Exception('Server error (${response.statusCode}). Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) print("Error in updatePlan: $e");
      rethrow;
    }
  }

  Future<PlanModel?> getActivePlan() async {
    final uri = Uri.parse('$baseUrl/plans/active');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) print("Fetching active plan...");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Active Plan Status: ${response.statusCode}");
        print("Active Plan Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        if (data == null) return null;
        
        // Handle list if returned unexpectedly
        if (data is List) {
          if (data.isEmpty) return null;
          return PlanModel.fromJson(data.first);
        }
        
        return PlanModel.fromJson(data);
      } else if (response.statusCode == 404) {
        // Many backends return 404 when no resource is found
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Failed to load active plan (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getActivePlan: $e");
      if (e.toString().contains('404')) return null;
      rethrow;
    }
  }
}
