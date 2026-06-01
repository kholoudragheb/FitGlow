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

  const coachUserId = '6a069c8e668cf282b93545bb';

  print("\n=== STEP 2: Client POST /chat/conversations ===");
  final startRes = await http.post(
    Uri.parse('$baseUrl/chat/conversations'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'recipientId': coachUserId,
      'initialMessage': "Hi Coach! I'm ready to start my journey.",
    }),
  );
  print("Start Status: ${startRes.statusCode}");
  print("Start Body: ${startRes.body}");
}
