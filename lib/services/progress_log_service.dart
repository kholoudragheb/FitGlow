import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/progress_log_model.dart';
import '../models/progress_stats_model.dart';
import '../models/metric_log_model.dart';
import '../models/goal_model.dart';
import '../utils/token_storage.dart';

class ProgressLogService {
  final String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<ProgressLogModel> createProgressLog(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/progress-logs');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Creating progress log...");
      print("Payload: ${jsonEncode(body)}");
    }

    try {
      final response = await http.post(
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
        return ProgressLogModel.fromJson(data);
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Validation failed. Please check your input.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Server error (${response.statusCode}). Please try again later.');
      }
    } catch (e) {
      if (kDebugMode) print("Error in createProgressLog: $e");
      rethrow;
    }
  }

  Future<List<ProgressLogModel>> getProgressLogs() async {
    final uri = Uri.parse('$baseUrl/progress-logs');
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
        return data.map((json) => ProgressLogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load logs: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getProgressLogs: $e");
      rethrow;
    }
  }

  Future<List<ProgressLogModel>> getMyProgressLogs() async {
    final uri = Uri.parse('$baseUrl/progress-logs/my-logs');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) print("Fetching my progress logs...");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("My Logs Status: ${response.statusCode}");
        print("My Logs Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        
        // Handle if response is wrapped in an object { "logs": [...] }
        if (data is Map && data.containsKey('logs')) {
          final List<dynamic> logs = data['logs'];
          return logs.map((json) => ProgressLogModel.fromJson(json)).toList();
        }
        
        // Handle if response is direct array
        if (data is List) {
          return data.map((json) => ProgressLogModel.fromJson(json)).toList();
        }
        
        return [];
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load my logs (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getMyProgressLogs: $e");
      rethrow;
    }
  }

  Future<ProgressStatsModel> getProgressStats() async {
    final uri = Uri.parse('$baseUrl/progress-logs/stats');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) print("Fetching progress stats...");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Stats Status: ${response.statusCode}");
        print("Stats Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProgressStatsModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return ProgressStatsModel.empty();
      } else {
        throw Exception('Failed to load stats (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getProgressStats: $e");
      // Return empty stats instead of crashing if possible, or rethrow
      return ProgressStatsModel.empty();
    }
  }

  Future<MetricLogModel> logMetrics(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/progress-logs/metrics');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Logging metrics...");
      print("Payload: ${jsonEncode(body)}");
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Metric Response Status: ${response.statusCode}");
        print("Metric Response Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MetricLogModel.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to log metrics (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in logMetrics: $e");
      rethrow;
    }
  }

  Future<List<MetricLogModel>> getMetricHistory() async {
    final uri = Uri.parse('$baseUrl/progress-logs/metrics');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) print("Fetching metric history...");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Metric History Status: ${response.statusCode}");
        print("Metric History Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        
        // Handle if response is wrapped in an object { "metrics": [...] }
        if (data is Map && data.containsKey('metrics')) {
          final List<dynamic> metrics = data['metrics'];
          return metrics.map((json) => MetricLogModel.fromJson(json)).toList();
        }
        
        // Handle if response is direct array
        if (data is List) {
          return data.map((json) => MetricLogModel.fromJson(json)).toList();
        }
        
        return [];
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load metric history (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getMetricHistory: $e");
      rethrow;
    }
  }

  // --- GOALS API ---

  Future<GoalModel> createGoal(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/progress-logs/goals');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Creating goal...");
      print("Payload: ${jsonEncode(body)}");
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Create Goal Status: ${response.statusCode}");
        print("Create Goal Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return GoalModel.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to create goal (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in createGoal: $e");
      rethrow;
    }
  }

  Future<List<GoalModel>> getGoals() async {
    final uri = Uri.parse('$baseUrl/progress-logs/goals');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) print("Fetching goals...");

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get Goals Status: ${response.statusCode}");
        print("Get Goals Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('goals')) {
          final List<dynamic> goals = data['goals'];
          return goals.map((json) => GoalModel.fromJson(json)).toList();
        }
        
        if (data is List) {
          return data.map((json) => GoalModel.fromJson(json)).toList();
        }
        
        return [];
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load goals (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getGoals: $e");
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final uri = Uri.parse('$baseUrl/progress-logs/goals/$goalId');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete goal');
      }
    } catch (e) {
      if (kDebugMode) print("Error in deleteGoal: $e");
      rethrow;
    }
  }

  Future<GoalModel> updateGoalProgress({
    required String goalId,
    required double currentValue,
  }) async {
    final uri = Uri.parse('$baseUrl/progress-logs/goals/$goalId');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Updating goal progress...");
      print("Goal ID: $goalId");
      print("New Value: $currentValue");
    }

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'currentValue': currentValue}),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Update Progress Status: ${response.statusCode}");
        print("Update Progress Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return GoalModel.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update progress (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in updateGoalProgress: $e");
      rethrow;
    }
  }

  Future<List<ProgressLogModel>> getLogsByPlan({required String planId}) async {
    final uri = Uri.parse('$baseUrl/progress-logs/plan/$planId');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching logs for plan: $planId");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Logs By Plan Status: ${response.statusCode}");
        print("Logs By Plan Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('logs')) {
          final List<dynamic> logs = data['logs'];
          return logs.map((json) => ProgressLogModel.fromJson(json)).toList();
        }
        
        if (data is List) {
          return data.map((json) => ProgressLogModel.fromJson(json)).toList();
        }
        
        return [];
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load logs for plan (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getLogsByPlan: $e");
      rethrow;
    }
  }

  Future<ProgressLogModel> getLogById({required String logId}) async {
    final uri = Uri.parse('$baseUrl/progress-logs/$logId');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching log details for: $logId");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Log Details Status: ${response.statusCode}");
        print("Log Details Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProgressLogModel.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load log details (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getLogById: $e");
      rethrow;
    }
  }
}
