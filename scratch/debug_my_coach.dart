import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  print("=== STEP 1: Logging in as Trial Client ===");
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_client_100@test.com", "password": "Password123!"}),
  );

  if (loginRes.statusCode != 200 && loginRes.statusCode != 201) {
    print("❌ Login failed: ${loginRes.body}");
    return;
  }
  final loginData = jsonDecode(loginRes.body);
  final token = loginData['access_token'] ?? loginData['data']?['accessToken'] ?? loginData['token'];

  print("\n=== STEP 2: GET /coach-client/my-coach ===");
  final myCoachRes = await http.get(
    Uri.parse('$baseUrl/coach-client/my-coach'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  print("Status: ${myCoachRes.statusCode}");
  print("Body: ${myCoachRes.body}");

  print("\n=== STEP 3: GET /coach-client/my-coaches (checking plural just in case) ===");
  final pluralRes = await http.get(
    Uri.parse('$baseUrl/coach-client/my-coaches'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  print("Plural Status: ${pluralRes.statusCode}");
  print("Plural Body: ${pluralRes.body}");
}
