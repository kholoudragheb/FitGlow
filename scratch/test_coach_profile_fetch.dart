import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  const coachUserId = '6a069c8e668cf282b93545bb'; // Trial Coach User ID

  print("=== STEP 1: Testing GET /coach-profile/$coachUserId (using User ID) ===");
  final res1 = await http.get(Uri.parse('$baseUrl/coach-profile/$coachUserId'));
  print("Status 1: ${res1.statusCode}");
  print("Body 1: ${res1.body}");

  print("\n=== STEP 2: Testing GET /coach-profile?userId=$coachUserId ===");
  final res2 = await http.get(Uri.parse('$baseUrl/coach-profile?userId=$coachUserId'));
  print("Status 2: ${res2.statusCode}");
  print("Body 2: ${res2.body}");

  print("\n=== STEP 3: Testing GET /coach-profile?search=Trial ===");
  final res3 = await http.get(Uri.parse('$baseUrl/coach-profile?search=Trial'));
  print("Status 3: ${res3.statusCode}");
  print("Body 3: ${res3.body}");
}
