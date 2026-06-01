class RegisterResponse {
  final bool isSuccess;
  final String? message;
  final String? errorType;
  final int statusCode;

  RegisterResponse({
    required this.isSuccess,
    this.message,
    this.errorType,
    required this.statusCode,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      return RegisterResponse(
        isSuccess: true,
        statusCode: statusCode,
      );
    }

    String? msg;
    String? errType;

    if (json['error'] != null && json['error'] is Map) {
      final errorData = json['error'];
      errType = errorData['error']?.toString();
      
      final messageData = errorData['message'];
      if (messageData is List) {
        msg = messageData.join(', ');
      } else {
        msg = messageData?.toString();
      }
    } else if (json['message'] != null) {
      final messageData = json['message'];
      if (messageData is List) {
        msg = messageData.join(', ');
      } else {
        msg = messageData?.toString();
      }
    }

    return RegisterResponse(
      isSuccess: false,
      message: msg ?? 'Registration failed. Please try again.',
      errorType: errType,
      statusCode: statusCode,
    );
  }

  factory RegisterResponse.withError(String errorMessage, {int statusCode = 500}) {
    return RegisterResponse(
      isSuccess: false,
      message: errorMessage,
      statusCode: statusCode,
    );
  }
}
