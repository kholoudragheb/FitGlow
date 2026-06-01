import 'user_model.dart';

class LoginResponse {
  final bool isSuccess;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;
  final int statusCode;
  /// True when the backend rejects login because email is not yet verified.
  final bool isEmailUnverified;

  LoginResponse({
    required this.isSuccess,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
    required this.statusCode,
    this.isEmailUnverified = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      return LoginResponse(
        isSuccess: true,
        statusCode: statusCode,
        accessToken: json['access_token'] ?? json['accessToken'] ?? json['token'],
        refreshToken: json['refresh_token'] ?? json['refreshToken'],
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      );
    }

    // Error parsing
    String? msg;
    if (json['error'] != null && json['error'] is Map) {
      final messageData = json['error']['message'];
      msg = messageData is List ? messageData.join(', ') : messageData?.toString();
    } else if (json['message'] != null) {
      final messageData = json['message'];
      msg = messageData is List ? messageData.join(', ') : messageData?.toString();
    }

    // Detect email-not-verified case (401 with relevant keywords)
    final lowerMsg = (msg ?? '').toLowerCase();
    final isEmailUnverified = statusCode == 401 &&
        (lowerMsg.contains('verif') ||
            lowerMsg.contains('not verified') ||
            lowerMsg.contains('email') ||
            lowerMsg.contains('confirm'));

    // Provide a clear user-facing message
    String userMessage;
    if (isEmailUnverified) {
      userMessage = 'Please verify your email before logging in.';
    } else if (statusCode == 401) {
      userMessage = msg ?? 'Invalid email or password. Please try again.';
    } else {
      userMessage = msg ?? 'Login failed. Please check your credentials.';
    }

    return LoginResponse(
      isSuccess: false,
      message: userMessage,
      statusCode: statusCode,
      isEmailUnverified: isEmailUnverified,
    );
  }

  factory LoginResponse.withError(String errorMessage, {int statusCode = 500}) {
    return LoginResponse(
      isSuccess: false,
      message: errorMessage,
      statusCode: statusCode,
    );
  }
}
