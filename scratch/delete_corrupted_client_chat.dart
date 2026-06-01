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

  const corruptedConvId = '6a08a4eda16dea8dcb03cd7f';

  print("\n=== STEP 2: Attempting DELETE /chat/conversations/$corruptedConvId as Client ===");
  final delClientRes = await http.delete(
    Uri.parse('$baseUrl/chat/conversations/$corruptedConvId'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("Del Client Status: ${delClientRes.statusCode}");
  print("Del Client Body: ${delClientRes.body}");

  print("\n=== STEP 3: Testing Client GET /chat/conversations ===");
  final clientConvRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("Client Convs Status: ${clientConvRes.statusCode}");
  print("Client Convs Body: ${clientConvRes.body}");
}
