import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/forgot_password_model.dart';
import '../models/reset_password_model.dart';
import '../models/refresh_token_model.dart';
import '../models/logout_model.dart';
import '../utils/token_storage.dart';

class AuthService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  /// Performs a login request to the backend.
  /// Returns a [LoginResponse] which contains the auth tokens and user data.
  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('$baseUrl/auth/login');

    // Clear any stale tokens before attempting login
    await TokenStorage.clearAll();

    final requestBody = jsonEncode(request.toJson());
    print('[AuthService] LOGIN REQUEST => POST $url');
    print('[AuthService] Login body: $requestBody');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      print('[AuthService] Login response status: ${response.statusCode}');
      print('[AuthService] Login response body: ${response.body}');

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
        print('[AuthService] Failed to decode JSON: $e');
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
      print('[AuthService] Login exception: $e');
      if (e is http.ClientException) {
        return LoginResponse.withError('Network error. Please check your connection.');
      }
      return LoginResponse.withError('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Submits a forgot password request to the backend.
  /// Returns a [ForgotPasswordResponse] containing the success status and message.
  Future<ForgotPasswordResponse> forgotPassword(ForgotPasswordRequest request) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('<html') || bodyLower.contains('service is almost ready')) {
        return ForgotPasswordResponse.withError(
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
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ForgotPasswordResponse(
            isSuccess: true,
            message: 'If the email exists, a reset OTP has been sent.',
            statusCode: response.statusCode,
          );
        }
        return ForgotPasswordResponse.withError(
          'Invalid response from server.',
          statusCode: response.statusCode,
        );
      }

      return ForgotPasswordResponse.fromJson(jsonResponse, response.statusCode);

    } on TimeoutException {
      return ForgotPasswordResponse.withError('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is http.ClientException) {
        return ForgotPasswordResponse.withError('Network error. Please check your connection.');
      }
      return ForgotPasswordResponse.withError('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Submits a reset password request to the backend.
  /// Returns a [ResetPasswordResponse] containing the success status and message.
  Future<ResetPasswordResponse> resetPassword(ResetPasswordRequest request) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');

    try {
      print('AuthService ResetPassword Request: ${request.toJson()}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('<html') || bodyLower.contains('service is almost ready')) {
        return ResetPasswordResponse.withError(
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
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ResetPasswordResponse(
            isSuccess: true,
            message: 'Password reset successfully.',
            statusCode: response.statusCode,
          );
        }
        return ResetPasswordResponse.withError(
          'Invalid response from server.',
          statusCode: response.statusCode,
        );
      }

      return ResetPasswordResponse.fromJson(jsonResponse, response.statusCode);

    } on TimeoutException {
      return ResetPasswordResponse.withError('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is http.ClientException) {
        return ResetPasswordResponse.withError('Network error. Please check your connection.');
      }
      return ResetPasswordResponse.withError('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Submits a request to refresh the access token using a valid refresh token.
  /// Returns a [RefreshTokenResponse] containing the newly generated token(s).
  Future<RefreshTokenResponse> refreshAuthToken(RefreshTokenRequest request) async {
    final url = Uri.parse('$baseUrl/auth/refresh');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('<html') || bodyLower.contains('service is almost ready')) {
        return RefreshTokenResponse.withError(
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
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return RefreshTokenResponse.withError(
            'Invalid JSON success response from server.',
            statusCode: response.statusCode,
          );
        }
        return RefreshTokenResponse.withError(
          'Invalid error response from server.',
          statusCode: response.statusCode,
        );
      }

      return RefreshTokenResponse.fromJson(jsonResponse, response.statusCode);

    } on TimeoutException {
      return RefreshTokenResponse.withError('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is http.ClientException) {
        return RefreshTokenResponse.withError('Network error. Please check your connection.');
      }
      return RefreshTokenResponse.withError('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Submits a request to logout the currently authenticated user.
  /// Needs Authorization header, so we fetch the access token from TokenStorage.
  Future<LogoutResponse> logout() async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final accessToken = await TokenStorage.getAccessToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 15));

      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('<html') || bodyLower.contains('service is almost ready')) {
        return LogoutResponse.withError(
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
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return LogoutResponse(
            isSuccess: true,
            message: 'Logged out successfully.',
            statusCode: response.statusCode,
          );
        }
        return LogoutResponse.withError(
          'Invalid response from server.',
          statusCode: response.statusCode,
        );
      }

      return LogoutResponse.fromJson(jsonResponse, response.statusCode);

    } on TimeoutException {
      return LogoutResponse.withError('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is http.ClientException) {
        return LogoutResponse.withError('Network error. Please check your connection.');
      }
      return LogoutResponse.withError('An unexpected error occurred: ${e.toString()}');
    }
  }
}




