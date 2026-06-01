import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/promo_code_model.dart';
import '../utils/token_storage.dart';

class PromoCodeService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<PromoCodeModel> validatePromoCode({required String code}) async {
    final url = Uri.parse('$baseUrl/promo-codes/validate');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Validating promo code: $code");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code.trim().toUpperCase()}),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Promo Validation Status: ${response.statusCode}");
        print("Promo Validation Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PromoCodeModel.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to validate promo code (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in validatePromoCode: $e");
      rethrow;
    }
  }
}
