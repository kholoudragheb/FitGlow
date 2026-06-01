import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  print("=== STEP 1: Fetching all coaches (GET /coach-profile) ===");
  final allRes = await http.get(Uri.parse('$baseUrl/coach-profile'));
  print("Status: ${allRes.statusCode}");
  if (allRes.statusCode == 200) {
    final List coaches = jsonDecode(allRes.body);
    print("Total coaches returned: ${coaches.length}");
    for (var c in coaches) {
      final name = "${c['firstName']} ${c['lastName']}";
      print(" - ID: ${c['_id'] ?? c['id']} | Name: $name | Verified: ${c['isVerified']} | Active: ${c['isActive']}");
    }
  } else {
    print("Body: ${allRes.body}");
  }

  print("\n=== STEP 2: Searching for 'Trial' (GET /coach-profile?search=Trial) ===");
  final searchRes = await http.get(Uri.parse('$baseUrl/coach-profile?search=Trial'));
  print("Status: ${searchRes.statusCode}");
  print("Body: ${searchRes.body}");

  print("\n=== STEP 3: Fetching Trial Coach directly by ID ===");
  const coachId = '6a069c8e668cf282b93545bb';
  final detailRes = await http.get(Uri.parse('$baseUrl/coach-profile/$coachId'));
  print("Status: ${detailRes.statusCode}");
  print("Body: ${detailRes.body}");
}
