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

  const convId = '6a069cb0668cf282b93545c3';

  print("\n=== STEP 2: Client GET /chat/conversations/$convId ===");
  final clientConvRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations/$convId'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("Client Conv Status: ${clientConvRes.statusCode}");
  print("Client Conv Body: ${clientConvRes.body}");

  print("\n=== STEP 3: Client GET /chat/conversations/$convId/messages ===");
  final clientMsgRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations/$convId/messages?limit=50'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("Client Msg Status: ${clientMsgRes.statusCode}");
  print("Client Msg Body: ${clientMsgRes.body}");
}
