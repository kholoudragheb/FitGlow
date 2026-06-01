import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  print("=== STEP 1: Testing Search for 'Weight' (specialty) ===");
  final specRes = await http.get(Uri.parse('$baseUrl/coach-profile?search=Weight'));
  print("Spec Search Status: ${specRes.statusCode}");
  print("Spec Search Body: ${specRes.body}");

  print("\n=== STEP 2: Fetching ALL Coaches (GET /coach-profile) ===");
  final allRes = await http.get(Uri.parse('$baseUrl/coach-profile'));
  if (allRes.statusCode == 200) {
    final List coaches = jsonDecode(allRes.body);
    print("Total coaches: ${coaches.length}");
    for (var c in coaches) {
      final userMap = c['userId'] is Map ? c['userId'] : {};
      final name = "${userMap['firstName']} ${userMap['lastName']}";
      final email = userMap['email'];
      print(" - ID: ${c['_id']} | Name: $name ($email) | Verified: ${c['isVerified']} | Specialties: ${c['specialties']}");
    }
  }
}
