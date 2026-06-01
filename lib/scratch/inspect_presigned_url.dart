import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fit_app/utils/token_storage.dart';

Future<void> main() async {
  try {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      print("Error: No token found. Please login first.");
      return;
    }

    final baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
    final response = await http.post(
      Uri.parse('$baseUrl/media/presigned-url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fileName': 'test_upload.jpg',
        'fileType': 'image/jpeg',
      }),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
  } catch (e) {
    print("Error: $e");
  }
}
