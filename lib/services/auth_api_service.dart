import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../utils/token_storage.dart';

class AuthApiService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  /// Registers a new user.
  /// Returns a [RegisterResponse] containing success status, message, and status code.
  Future<RegisterResponse> register(RegisterRequest request) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      // Handle HTML or "waking up" service responses gracefully
      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('<html') || bodyLower.contains('service is almost ready')) {
        return RegisterResponse.withError(
          'Service is starting up. Please try again in a moment.',
          statusCode: 503,
        );
      }

      Map<String, dynamic> jsonResponse = {};
      try {
        if (response.body.isNotEmpty) {
          jsonResponse = jsonDecode(response.body);
        }
      } catch (e) {
        // If not JSON but status is 20X, handle as success.
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return RegisterResponse(
            isSuccess: true,
            statusCode: response.statusCode,
          );
        }
        return RegisterResponse.withError(
          'Invalid response from server.',
          statusCode: response.statusCode,
        );
      }

      return RegisterResponse.fromJson(jsonResponse, response.statusCode);

    } on TimeoutException {
      return RegisterResponse.withError('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is http.ClientException) {
        return RegisterResponse.withError('Network error. Please check your connection.');
      }
      return RegisterResponse.withError('An unexpected error occurred.');
    }
  }

  /// Logs in an existing user.
  /// Returns a [LoginResponse] containing success status, token, and message.
  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('$baseUrl/auth/login');

    // Clear any stale tokens before attempting login
    await TokenStorage.clearAll();

    final requestBody = jsonEncode(request.toJson());
    print('[AuthApiService] LOGIN REQUEST => POST $url');
    // print('[AuthApiService] Login body: $requestBody'); // Removed for security

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      print('[AuthApiService] Login response status: ${response.statusCode}');
      print('[AuthApiService] Login response body: ${response.body}');

      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('<html') || bodyLower.contains('service is almost ready')) {
        return LoginResponse.withError(
          'Service is starting up. Please try again in a moment.',
          statusCode: 503,
        );
      }

      Map<String, dynamic> jsonResponse = {};
      try {
        if (response.body.isNotEmpty) {
          jsonResponse = jsonDecode(response.body);
        }
      } catch (e) {
        print('[AuthApiService] Failed to decode JSON: $e');
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return LoginResponse(
            isSuccess: true,
            statusCode: response.statusCode,
          );
        }
        return LoginResponse.withError(
          'Invalid response from server.',
          statusCode: response.statusCode,
        );
      }

      return LoginResponse.fromJson(jsonResponse, response.statusCode);

    } on TimeoutException {
      return LoginResponse.withError('Connection timed out. Please try again later.');
    } catch (e) {
      print('[AuthApiService] Login exception: $e');
      if (e is http.ClientException) {
        return LoginResponse.withError('Network error. Please check your connection.');
      }
      return LoginResponse.withError('An unexpected error occurred: ${e.toString()}');
    }
  }
}
