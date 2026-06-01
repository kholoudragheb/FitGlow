class LogoutResponse {
  final bool isSuccess;
  final String? message;
  final int statusCode;

  LogoutResponse({
    required this.isSuccess,
    this.message,
    required this.statusCode,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      return LogoutResponse(
        isSuccess: true,
        message: json['message']?.toString() ?? 'Logged out successfully.',
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

    return LogoutResponse(
      isSuccess: false,
      message: msg ?? 'Failed to logout.',
      statusCode: statusCode,
    );
  }

  factory LogoutResponse.withError(String errorMessage, {int statusCode = 500}) {
    return LogoutResponse(
      isSuccess: false,
      message: errorMessage,
      statusCode: statusCode,
    );
  }
}
