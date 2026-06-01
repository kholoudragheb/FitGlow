class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    };
  }
}

class ResetPasswordResponse {
  final bool isSuccess;
  final String? message;
  final int statusCode;

  ResetPasswordResponse({
    required this.isSuccess,
    this.message,
    required this.statusCode,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      return ResetPasswordResponse(
        isSuccess: true,
        message: json['message']?.toString() ?? 'Password reset successfully.',
        statusCode: statusCode,
      );
    }

    String? msg;
    if (json['error'] != null && json['error'] is Map) {
      final messageData = json['error']['message'];
      msg = messageData is List ? messageData.join(', ') : messageData?.toString();
    } else if (json['message'] != null) {
      final messageData = json['message'];
      msg = messageData is List ? messageData.join(', ') : messageData?.toString();
    }

    return ResetPasswordResponse(
      isSuccess: false,
      message: msg ?? 'Failed to reset password. Please try again.',
      statusCode: statusCode,
    );
  }

  factory ResetPasswordResponse.withError(String errorMessage, {int statusCode = 500}) {
    return ResetPasswordResponse(
      isSuccess: false,
      message: errorMessage,
      statusCode: statusCode,
    );
  }
}
