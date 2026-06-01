import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/send_otp_model.dart';
import '../models/verify_otp_model.dart';

class OtpService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  /// Performs a request to send an OTP to the given email.
  /// Returns a [SendOtpResponse] containing the success status and message.
  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    final url = Uri.parse('$baseUrl/auth/send-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('<html') || bodyLower.contains('service is almost ready')) {
        return SendOtpResponse.withError(
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
          return SendOtpResponse(
            isSuccess: true,
            message: 'OTP sent successfully',
            statusCode: response.statusCode,
          );
        }
        return SendOtpResponse.withError(
          'Invalid response from server.',
          statusCode: response.statusCode,
        );
      }

      return SendOtpResponse.fromJson(jsonResponse, response.statusCode);

    } on TimeoutException {
      return SendOtpResponse.withError('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is http.ClientException) {
        return SendOtpResponse.withError('Network error. Please check your connection.');
      }
      return SendOtpResponse.withError('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Performs a request to verify the given OTP for an email.
  /// Returns a [VerifyOtpResponse] containing the success status and message.
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      final bodyLower = response.body.toLowerCase();
      if (bodyLower.contains('<html') || bodyLower.contains('service is almost ready')) {
        return VerifyOtpResponse.withError(
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
          return VerifyOtpResponse(
            isSuccess: true,
            message: 'OTP verified successfully.',
            statusCode: response.statusCode,
          );
        }
        return VerifyOtpResponse.withError(
          'Invalid response from server.',
          statusCode: response.statusCode,
        );
      }

      return VerifyOtpResponse.fromJson(jsonResponse, response.statusCode);

    } on TimeoutException {
      return VerifyOtpResponse.withError('Connection timed out. Please try again later.');
    } catch (e) {
      if (e is http.ClientException) {
        return VerifyOtpResponse.withError('Network error. Please check your connection.');
      }
      return VerifyOtpResponse.withError('An unexpected error occurred: ${e.toString()}');
    }
  }
}

