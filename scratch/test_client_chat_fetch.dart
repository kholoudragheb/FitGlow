import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  const clientEmail = "trial_client_416518@test.com";

  print("=== STEP 1: Logging in as Client ($clientEmail) ===");
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": clientEmail, "password": "Password123!"}),
  );
  final data = jsonDecode(loginRes.body);
  final token = data['access_token'] ?? data['data']?['accessToken'] ?? data['token'] ?? '';

  print("\n=== STEP 2: GET /chat/conversations ===");
  final convRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  print("Conversations Status: ${convRes.statusCode}");
  print("Conversations Body: ${convRes.body}");

  if (convRes.statusCode == 200) {
    final list = jsonDecode(convRes.body) as List;
    for (var c in list) {
      final cId = c['_id'] ?? c['id'];
      print("\n=== STEP 3: GET /chat/conversations/$cId ===");
      final detailRes = await http.get(
        Uri.parse('$baseUrl/chat/conversations/$cId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("Detail Status: ${detailRes.statusCode}");
      print("Detail Body: ${detailRes.body}");

      print("\n=== STEP 4: GET /chat/conversations/$cId/messages ===");
      final msgRes = await http.get(
        Uri.parse('$baseUrl/chat/conversations/$cId/messages?limit=50'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("Messages Status: ${msgRes.statusCode}");
      print("Messages Body: ${msgRes.body}");
    }
  }
}
