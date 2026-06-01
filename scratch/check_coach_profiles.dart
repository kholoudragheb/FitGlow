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

  print("\n=== STEP 2: Fetching All Coaches ===");
  final res = await http.get(
    Uri.parse('$baseUrl/coach-profile'),
    headers: {
      'Authorization': 'Bearer $coachToken',
      'Content-Type': 'application/json',
    },
  );
  
  if (res.statusCode == 200) {
    final list = jsonDecode(res.body) as List;
    for (var coach in list) {
      print("Coach Profile ID: ${coach['_id']} | User ID: ${coach['userId']?['_id'] ?? coach['userId']} | Name: ${coach['userId']?['firstName']} ${coach['userId']?['lastName']} | Email: ${coach['userId']?['email']}");
    }
  } else {
    print("Failed to fetch coaches: ${res.statusCode} ${res.body}");
  }
}
