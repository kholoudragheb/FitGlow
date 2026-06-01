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

  print("\n=== STEP 2: Fetching messages for 6a069cb0668cf282b93545c3 ===");
  final msgRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations/6a069cb0668cf282b93545c3/messages?limit=10'),
    headers: {'Authorization': 'Bearer $clientToken', 'Content-Type': 'application/json'},
  );
  print("Messages Status: ${msgRes.statusCode}");
  
  if (msgRes.statusCode == 200) {
    final decoded = jsonDecode(msgRes.body);
    final List msgs = decoded is List ? decoded : (decoded['messages'] ?? decoded['data'] ?? []);
    print("Found ${msgs.length} messages.");
    
    if (msgs.isNotEmpty) {
      final firstMsg = msgs.first;
      final msgId = firstMsg['_id'] ?? firstMsg['id'];
      print("\n=== STEP 3: Attempting to delete message $msgId ===");
      final delRes = await http.delete(
        Uri.parse('$baseUrl/chat/messages/$msgId'),
        headers: {'Authorization': 'Bearer $clientToken', 'Content-Type': 'application/json'},
      );
      print("Delete Status: ${delRes.statusCode}");
      print("Delete Body: ${delRes.body}");
    }
  }
}
