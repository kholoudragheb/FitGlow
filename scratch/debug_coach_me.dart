import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  print("=== STEP 1: Logging in as Trial Coach ===");
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_coach_100@test.com", "password": "Password123!"}),
  );

  if (loginRes.statusCode != 200 && loginRes.statusCode != 201) {
    print("❌ Login failed: ${loginRes.body}");
    return;
  }
  final loginData = jsonDecode(loginRes.body);
  final token = loginData['access_token'] ?? loginData['data']?['accessToken'] ?? loginData['token'];

  print("\n=== STEP 2: GET /coach-profile/me ===");
  final meRes = await http.get(
    Uri.parse('$baseUrl/coach-profile/me'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  print("GET me Status: ${meRes.statusCode}");
  print("GET me Body: ${meRes.body}");

  String profileId = '6a08a037a16dea8dcb03cc68';
  if (meRes.statusCode == 200) {
    final meData = jsonDecode(meRes.body);
    profileId = meData['_id'] ?? meData['id'] ?? profileId;
  }

  final updateBody = {
    "bio": "Expert Fitness & Nutrition Coach with over 8 years of experience helping clients achieve their dream physique.",
    "specialties": ["Weight Loss", "Muscle Gain", "Strength Training"],
    "experienceYears": 8,
    "certifications": ["ISSA Certified Personal Trainer", "Precision Nutrition Level 1"],
    "socialLinks": {"instagram": "https://instagram.com/fitglow_coach"},
    "isVerified": true,
    "isActive": true
  };

  print("\n=== STEP 3: Testing PUT /coach-profile/me ===");
  final putMeRes = await http.put(
    Uri.parse('$baseUrl/coach-profile/me'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updateBody),
  );
  print("PUT me Status: ${putMeRes.statusCode}");
  print("PUT me Body: ${putMeRes.body}");

  print("\n=== STEP 4: Testing PATCH /coach-profile/me ===");
  final patchMeRes = await http.patch(
    Uri.parse('$baseUrl/coach-profile/me'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updateBody),
  );
  print("PATCH me Status: ${patchMeRes.statusCode}");
  print("PATCH me Body: ${patchMeRes.body}");

  print("\n=== STEP 5: Testing PUT /coach-profile/$profileId ===");
  final putIdRes = await http.put(
    Uri.parse('$baseUrl/coach-profile/$profileId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updateBody),
  );
  print("PUT id Status: ${putIdRes.statusCode}");
  print("PUT id Body: ${putIdRes.body}");

  print("\n=== STEP 6: Testing PATCH /coach-profile/$profileId ===");
  final patchIdRes = await http.patch(
    Uri.parse('$baseUrl/coach-profile/$profileId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updateBody),
  );
  print("PATCH id Status: ${patchIdRes.statusCode}");
  print("PATCH id Body: ${patchIdRes.body}");

  print("\n=== STEP 7: Testing Search for 'Trial' ===");
  final searchRes = await http.get(Uri.parse('$baseUrl/coach-profile?search=Trial'));
  print("Search Status: ${searchRes.statusCode}");
  print("Search Body: ${searchRes.body}");
}
