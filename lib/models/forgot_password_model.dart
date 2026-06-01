class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ForgotPasswordResponse {
  final bool isSuccess;
  final String? message;
  final int statusCode;

  ForgotPasswordResponse({
    required this.isSuccess,
    this.message,
    required this.statusCode,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      return ForgotPasswordResponse(
        isSuccess: true,
        message: json['message']?.toString() ?? 'If the email exists, a reset OTP has been sent.',
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

    return ForgotPasswordResponse(
      isSuccess: false,
      message: msg ?? 'Failed to process request. Please try again.',
      statusCode: statusCode,
    );
  }

  factory ForgotPasswordResponse.withError(String errorMessage, {int statusCode = 500}) {
    return ForgotPasswordResponse(
      isSuccess: false,
      message: errorMessage,
      statusCode: statusCode,
    );
  }
}
