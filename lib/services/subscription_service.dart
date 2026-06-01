import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_response_model.dart';
import '../models/subscription_status_model.dart';
import '../models/refresh_token_model.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

class SubscriptionService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<SubscriptionStatusModel> getSubscriptionStatus() async {
    final url = Uri.parse('$baseUrl/payments/subscription-status');
    String? token = await TokenStorage.getAccessToken();

    debugPrint('[SubscriptionService] GET $url');

    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // 401 → refresh token and retry once
    if (response.statusCode == 401) {
      debugPrint('[SubscriptionService] 401 on status — refreshing token...');
      token = await _refreshToken();
      response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    }

    debugPrint('[SubscriptionService] Subscription status ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SubscriptionStatusModel.fromJson(data);
    } else {
      // On any unexpected error return "none" so the app degrades gracefully
      debugPrint('[SubscriptionService] Could not fetch status — returning none');
      return SubscriptionStatusModel.none();
    }
  }

  Future<List<SubscriptionPlan>> getPlans() async {
    final url = Uri.parse('$baseUrl/payments/plans');
    
    // We optionally provide access token just in case regional or discount overrides apply to logged in users
    String? token = await TokenStorage.getAccessToken();
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        
        if (data is List) {
          return data.map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List).map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>)).toList();
        }
        
        return [];
      } else {
        throw Exception('Failed to load subscription plans. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching subscription plans: $e");
      throw Exception('Network error: Could not reach the server to grab live subscription plans.');
    }
  }

  Future<void> checkout({
    required String planId,
    required String coachId,
  }) async {
    final url = Uri.parse('$baseUrl/payments/mock/checkout');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) print("Mock checkout plan: $planId, Coach ID: $coachId");

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "planId": planId,
        "coachId": coachId,
      }),
    );

    if (response.statusCode == 401) {
      token = await _refreshToken();
      response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "planId": planId,
          "coachId": coachId,
        }),
      );
    }

    if (kDebugMode) print("Checkout Response: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to perform checkout block. (Status ${response.statusCode})");
    }
  }

  Future<SubscriptionResponse> confirmSubscription({
    required String planId,
    required String coachId,
  }) async {
    final url = Uri.parse('$baseUrl/payments/mock/confirm');
    String? token = await TokenStorage.getAccessToken();
    
    if (kDebugMode) print("Confirming subscription... Plan: $planId");

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "planId": planId,
        "coachId": coachId,
      }),
    );

    if (response.statusCode == 401) {
      token = await _refreshToken();
      response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "planId": planId,
          "coachId": coachId,
        }),
      );
    }

    if (kDebugMode) print("Confirmation Response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final res = SubscriptionResponse.fromJson(data);
      if (!res.success) {
        throw Exception("Subscription failed internally on the backend.");
      }
      return res;
    } else {
      throw Exception('Failed to confirm plan. (Status ${response.statusCode})');
    }
  }

  Future<CancelSubscriptionResponse> cancelSubscription() async {
    final url = Uri.parse('$baseUrl/payments/mock/cancel');
    String? token = await TokenStorage.getAccessToken();

    debugPrint('[SubscriptionService] Canceling subscription...');
    debugPrint('[SubscriptionService] POST $url');

    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // Handle 401 — refresh and retry once
    if (response.statusCode == 401) {
      debugPrint('[SubscriptionService] 401 received — refreshing token...');
      token = await _refreshToken();
      response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    }

    debugPrint('[SubscriptionService] Cancel response ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = CancelSubscriptionResponse.fromJson(data);
      if (!result.success) {
        throw Exception('Cancellation rejected by server: ${result.message}');
      }
      return result;
    } else {
      throw Exception(
          'Failed to cancel subscription (Status ${response.statusCode}): ${response.body}');
    }
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken != null) {
      final authService = AuthService();
      final refreshRes = await authService.refreshAuthToken(RefreshTokenRequest(refreshToken: refreshToken));
      if (refreshRes.isSuccess && refreshRes.accessToken != null) {
        await TokenStorage.saveTokens(
          accessToken: refreshRes.accessToken!,
          refreshToken: refreshRes.refreshToken,
        );
        return refreshRes.accessToken;
      }
    }
    return null;
  }
}
