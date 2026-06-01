class SendOtpRequest {
  final String email;

  SendOtpRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class SendOtpResponse {
  final bool isSuccess;
  final String? message;
  final int statusCode;

  SendOtpResponse({
    required this.isSuccess,
    this.message,
    required this.statusCode,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      return SendOtpResponse(
        isSuccess: true,
        message: json['message']?.toString() ?? 'OTP sent successfully',
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

    return SendOtpResponse(
      isSuccess: false,
      message: msg ?? 'Failed to send OTP. Please try again.',
      statusCode: statusCode,
    );
  }

  factory SendOtpResponse.withError(String errorMessage, {int statusCode = 500}) {
    return SendOtpResponse(
      isSuccess: false,
      message: errorMessage,
      statusCode: statusCode,
    );
  }
}
