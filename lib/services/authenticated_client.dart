import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';
import '../services/auth_service.dart';
import '../models/refresh_token_model.dart';

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isRefreshing = false;

  AuthenticatedClient({required this.navigatorKey});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Get the current access token
    final accessToken = await TokenStorage.getAccessToken();

    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    // 2. Make the initial request
    http.StreamedResponse response = await _inner.send(request);

    // 3. If the response is 401 Unauthorized, maybe the token expired
    if (response.statusCode == 401 && !_isRefreshing) {
      print("API error: 401 Unauthorized received. Attempting to refresh token...");
      _isRefreshing = true;

      final refreshToken = await TokenStorage.getRefreshToken();
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        // Attempt to refresh the token using AuthService
        final authService = AuthService();
        final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);
        final refreshResponse = await authService.refreshAuthToken(refreshRequest);

        if (refreshResponse.isSuccess && refreshResponse.accessToken != null) {
          // Save the new tokens
          await TokenStorage.saveTokens(
            accessToken: refreshResponse.accessToken!,
            refreshToken: refreshResponse.refreshToken, // typically backend sends a new one or keeps old
          );

          // Retry the original request
          final newAccessToken = refreshResponse.accessToken!;
          
          // To retry we have to clone the request since StreamedRequests can't be reused easily
          final retryRequest = _cloneRequest(request);
          retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          
          _isRefreshing = false;
          return await _inner.send(retryRequest);
        } else {
          // Token refresh failed, so we must force logout
          print("API error: Token refresh failed. Forcing logout.");
          _handleLogout();
        }
      } else {
        // No refresh token available, force logout
        print("API error: No refresh token available. Forcing logout.");
        _handleLogout();
      }

      _isRefreshing = false;
    }

    return response;
  }

  void _handleLogout() async {
    await TokenStorage.clearAll();
    
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    
    // Clear all routes and redirect home/login
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please log in again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Utility to cleanly clone a BaseRequest so it can be retried 
  // without the HTTP client throwing "Request already sent" error.
  http.BaseRequest _cloneRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final req = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..encoding = request.encoding
        ..bodyBytes = request.bodyBytes;
      return req;
    } else if (request is http.MultipartRequest) {
      final req = http.MultipartRequest(request.method, request.url)
        ..headers.addAll(request.headers)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
      return req;
    }
    // Fallback block if an unknown nested type passes through
    throw UnimplementedError('Cannot clone request of type ${request.runtimeType}');
  }
}
