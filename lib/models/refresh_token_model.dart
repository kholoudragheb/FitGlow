class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }
}

class RefreshTokenResponse {
  final bool isSuccess;
  final String? accessToken;
  final String? refreshToken;
  final String? message;
  final int statusCode;

  RefreshTokenResponse({
    required this.isSuccess,
    this.accessToken,
    this.refreshToken,
    this.message,
    required this.statusCode,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    if (statusCode == 200 || statusCode == 201) {
      return RefreshTokenResponse(
        isSuccess: true,
        accessToken: json['access_token'],
        refreshToken: json['refresh_token'],
        message: 'Token refreshed successfully.',
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

    return RefreshTokenResponse(
      isSuccess: false,
      message: msg ?? 'Failed to refresh token. Please log in again.',
      statusCode: statusCode,
    );
  }

  factory RefreshTokenResponse.withError(String errorMessage, {int statusCode = 500}) {
    return RefreshTokenResponse(
      isSuccess: false,
      message: errorMessage,
      statusCode: statusCode,
    );
  }
}
