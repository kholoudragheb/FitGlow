import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  print("=== STEP 1: Logging in as Trial Coach ===");
  final coachLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_coach_100@test.com", "password": "Password123!"}),
  );
  final coachData = jsonDecode(coachLoginRes.body);
  final coachToken = coachData['access_token'] ?? coachData['data']?['accessToken'] ?? coachData['token'];

  print("\n=== STEP 2: Logging in as Trial Client ===");
  final clientLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_client_100@test.com", "password": "Password123!"}),
  );
  final clientData = jsonDecode(clientLoginRes.body);
  final clientToken = clientData['access_token'] ?? clientData['data']?['accessToken'] ?? clientData['token'];

  const convId = '6a069cb0668cf282b93545c3';

  print("\n=== STEP 3: Attempting DELETE /chat/conversations/$convId as Coach ===");
  final delCoachRes = await http.delete(
    Uri.parse('$baseUrl/chat/conversations/$convId'),
    headers: {
      'Authorization': 'Bearer $coachToken',
      'Content-Type': 'application/json',
    },
  );
  print("Del Coach Status: ${delCoachRes.statusCode}");
  print("Del Coach Body: ${delCoachRes.body}");

  print("\n=== STEP 4: Attempting DELETE /chat/conversations/$convId as Client ===");
  final delClientRes = await http.delete(
    Uri.parse('$baseUrl/chat/conversations/$convId'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("Del Client Status: ${delClientRes.statusCode}");
  print("Del Client Body: ${delClientRes.body}");

  print("\n=== STEP 5: Testing Client GET /chat/conversations ===");
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
