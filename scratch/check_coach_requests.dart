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
  final coachToken = coachData['access_token'] ?? coachData['data']?['accessToken'] ?? coachData['token'] ?? '';

  print("\n=== STEP 2: Coach GET /coach-profile/me ===");
  final meRes = await http.get(
    Uri.parse('$baseUrl/coach-profile/me'),
    headers: {
      'Authorization': 'Bearer $coachToken',
      'Content-Type': 'application/json',
    },
  );
  print("Me Status: ${meRes.statusCode}");
  print("Me Body: ${meRes.body}");

  print("\n=== STEP 3: Coach GET /coach-client/pending-requests ===");
  final pendingRes = await http.get(
    Uri.parse('$baseUrl/coach-client/pending-requests'),
    headers: {
      'Authorization': 'Bearer $coachToken',
      'Content-Type': 'application/json',
    },
  );
  print("Pending Status: ${pendingRes.statusCode}");
  print("Pending Body: ${pendingRes.body}");
}
