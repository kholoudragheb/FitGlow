import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  const clientEmail = "trial_client_416518@test.com";

  print("=== STEP 1: Logging in as New Client ($clientEmail) ===");
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": clientEmail, "password": "Password123!"}),
  );

  final loginData = jsonDecode(loginRes.body);
  final clientToken = loginData['access_token'] ?? loginData['data']?['accessToken'] ?? loginData['token'] ?? '';
  print("Login Status: ${loginRes.statusCode}");

  const coachUserId = '6a069c8e668cf282b93545bb';

  print("\n=== STEP 2: Starting Conversation with Trial Coach ===");
  final startRes = await http.post(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'recipientId': coachUserId,
      'initialMessage': "Hello Coach! I am the fresh client ready to train.",
    }),
  );
  print("Start Status: ${startRes.statusCode}");
  print("Start Body: ${startRes.body}");

  print("\n=== STEP 3: Testing GET /chat/conversations ===");
  final convRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("Convs Status: ${convRes.statusCode}");
  print("Convs Body: ${convRes.body}");
}
