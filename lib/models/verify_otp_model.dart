class VerifyOtpRequest {
  final String email;
  final String otp;

  VerifyOtpRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}

class VerifyOtpResponse {
  final bool isSuccess;
  final String? message;
  final int statusCode;

  VerifyOtpResponse({
    required this.isSuccess,
    this.message,
    required this.statusCode,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      return VerifyOtpResponse(
        isSuccess: true,
        message: json['message']?.toString() ?? 'OTP verified successfully.',
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

    return VerifyOtpResponse(
      isSuccess: false,
      message: msg ?? 'Invalid OTP. Please try again.',
      statusCode: statusCode,
    );
  }

  factory VerifyOtpResponse.withError(String errorMessage, {int statusCode = 500}) {
    return VerifyOtpResponse(
      isSuccess: false,
      message: errorMessage,
      statusCode: statusCode,
    );
  }
}
