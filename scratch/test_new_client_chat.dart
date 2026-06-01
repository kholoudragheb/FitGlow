import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  final uniqueSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  final clientEmail = "trial_client_$uniqueSuffix@test.com";

  print("=== STEP 1: Registering New Client ($clientEmail) ===");
  final regRes = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": clientEmail,
      "password": "Password123!",
      "firstName": "Fresh",
      "lastName": "Client",
      "role": "Customer"
    }),
  );
  
  print("Reg Status: ${regRes.statusCode}");

  print("\n=== STEP 2: Logging in to get token ===");
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": clientEmail, "password": "Password123!"}),
  );

  final loginData = jsonDecode(loginRes.body);
  final clientToken = loginData['access_token'] ?? loginData['data']?['accessToken'] ?? loginData['token'] ?? '';
  print("Login Status: ${loginRes.statusCode}");

  print("\n=== STEP 3: Testing GET /chat/conversations as New Client ===");
  final convRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("New Client Convs Status: ${convRes.statusCode}");
  print("New Client Convs Body: ${convRes.body}");

  print("\n=== STEP 4: Testing GET /ai/history as New Client ===");
  final aiRes = await http.get(
    Uri.parse('$baseUrl/ai/history'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("New Client AI Status: ${aiRes.statusCode}");
  print("New Client AI Body: ${aiRes.body}");
}
