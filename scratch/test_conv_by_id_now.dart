import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  print("=== STEP 1: Logging in as Trial Client ===");
  final clientLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_client_100@test.com", "password": "Password123!"}),
  );
  final clientData = jsonDecode(clientLoginRes.body);
  final clientToken = clientData['access_token'] ?? clientData['data']?['accessToken'] ?? clientData['token'];

  print("\n=== STEP 2: Testing GET /chat/conversations/6a069cb0668cf282b93545c3 ===");
  final res1 = await http.get(
    Uri.parse('$baseUrl/chat/conversations/6a069cb0668cf282b93545c3'),
    headers: {'Authorization': 'Bearer $clientToken', 'Content-Type': 'application/json'},
  );
  print("Status 1: ${res1.statusCode}");
  print("Body 1: ${res1.body}");

  print("\n=== STEP 3: Testing GET /chat/conversations/6a08a4eda16dea8dcb03cd7f ===");
  final res2 = await http.get(
    Uri.parse('$baseUrl/chat/conversations/6a08a4eda16dea8dcb03cd7f'),
    headers: {'Authorization': 'Bearer $clientToken', 'Content-Type': 'application/json'},
  );
  print("Status 2: ${res2.statusCode}");
  print("Body 2: ${res2.body}");
}
