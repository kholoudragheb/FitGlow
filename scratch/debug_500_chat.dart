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

  print("\n=== STEP 2: Coach GET /chat/conversations ===");
  final coachConvRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      'Authorization': 'Bearer $coachToken',
      'Content-Type': 'application/json',
    },
  );
  print("Coach Convs Status: ${coachConvRes.statusCode}");
  print("Coach Convs Body: ${coachConvRes.body}");

  print("\n=== STEP 3: Logging in as Trial Client ===");
  final clientLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_client_100@test.com", "password": "Password123!"}),
  );
  final clientData = jsonDecode(clientLoginRes.body);
  final clientToken = clientData['access_token'] ?? clientData['data']?['accessToken'] ?? clientData['token'];

  print("\n=== STEP 4: Client GET /chat/conversations ===");
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
