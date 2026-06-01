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

  print("\n=== STEP 2: Updating Profile with isVerified = true ===");
  final updateBody = {
    "bio": "Expert Fitness & Nutrition Coach with over 8 years of experience helping clients achieve their dream physique.",
    "specialties": ["Weight Loss", "Muscle Gain", "Strength Training"],
    "experienceYears": 8,
    "certifications": ["ISSA Certified Personal Trainer", "Precision Nutrition Level 1"],
    "socialLinks": {"instagram": "https://instagram.com/fitglow_coach"},
    "isVerified": true,
    "isActive": true
  };

  final updateRes = await http.put(
    Uri.parse('$baseUrl/coach-profile'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updateBody),
  );
  print("Update Status: ${updateRes.statusCode}");
  print("Update Body: ${updateRes.body}");

  print("\n=== STEP 3: Testing Search for 'Trial' ===");
  final searchRes = await http.get(Uri.parse('$baseUrl/coach-profile?search=Trial'));
  print("Search Status: ${searchRes.statusCode}");
  print("Search Body: ${searchRes.body}");

  print("\n=== STEP 4: Testing Search for 'Weight' (specialty) ===");
  final specRes = await http.get(Uri.parse('$baseUrl/coach-profile?search=Weight'));
  print("Spec Search Status: ${specRes.statusCode}");
  print("Spec Search Body: ${specRes.body}");
}
