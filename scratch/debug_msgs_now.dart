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
  final clientUserId = clientData['user']?['_id'] ?? clientData['data']?['user']?['_id'] ?? clientData['userId'];
  print("Client User ID: $clientUserId");

  print("\n=== STEP 2: Logging in as Trial Coach ===");
  final coachLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_coach_100@test.com", "password": "Password123!"}),
  );
  final coachData = jsonDecode(coachLoginRes.body);
  final coachToken = coachData['access_token'] ?? coachData['data']?['accessToken'] ?? coachData['token'];
  final coachUserId = coachData['user']?['_id'] ?? coachData['data']?['user']?['_id'] ?? coachData['userId'];
  print("Coach User ID: $coachUserId");

  print("\n=== STEP 3: Fetching messages for 6a069cb0668cf282b93545c3 ===");
  final msgRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations/6a069cb0668cf282b93545c3/messages?limit=10'),
    headers: {'Authorization': 'Bearer $clientToken', 'Content-Type': 'application/json'},
  );
  print("Messages Status: ${msgRes.statusCode}");
  
  if (msgRes.statusCode == 200) {
    final decoded = jsonDecode(msgRes.body);
    final List msgs = decoded is List ? decoded : (decoded['messages'] ?? decoded['data'] ?? []);
    print("Found ${msgs.length} messages.\n");
    
    for (var m in msgs) {
      final id = m['_id'] ?? m['id'];
      final sender = m['senderId'] ?? m['sender'];
      final senderId = sender is Map ? (sender['_id'] ?? sender['id']) : sender;
      final content = m['content'] ?? m['text'];
      final isDel = m['isDeleted'] ?? m['deleted'] ?? false;
      print("ID: $id | Sender: $senderId | isDeleted: $isDel | Content: $content");

      // Let's test deleting this message using the correct token
      if (senderId == clientUserId) {
        print("  -> Deleting as Client...");
        final delRes = await http.delete(
          Uri.parse('$baseUrl/chat/messages/$id'),
          headers: {'Authorization': 'Bearer $clientToken', 'Content-Type': 'application/json'},
        );
        print("  -> Client Delete Status: ${delRes.statusCode} | Body: ${delRes.body}");
      } else if (senderId == coachUserId) {
        print("  -> Deleting as Coach...");
        final delRes = await http.delete(
          Uri.parse('$baseUrl/chat/messages/$id'),
          headers: {'Authorization': 'Bearer $coachToken', 'Content-Type': 'application/json'},
        );
        print("  -> Coach Delete Status: ${delRes.statusCode} | Body: ${delRes.body}");
      } else {
        print("  -> Unknown sender $senderId, skipping delete.");
      }
    }

    print("\n=== STEP 4: Fetching messages AGAIN to see if they are gone/updated ===");
    final msgRes2 = await http.get(
      Uri.parse('$baseUrl/chat/conversations/6a069cb0668cf282b93545c3/messages?limit=10'),
      headers: {'Authorization': 'Bearer $clientToken', 'Content-Type': 'application/json'},
    );
    if (msgRes2.statusCode == 200) {
      final decoded2 = jsonDecode(msgRes2.body);
      final List msgs2 = decoded2 is List ? decoded2 : (decoded2['messages'] ?? decoded2['data'] ?? []);
      print("Found ${msgs2.length} messages after deletion attempts:\n");
      for (var m in msgs2) {
        final id = m['_id'] ?? m['id'];
        final sender = m['senderId'] ?? m['sender'];
        final senderId = sender is Map ? (sender['_id'] ?? sender['id']) : sender;
        final content = m['content'] ?? m['text'];
        final isDel = m['isDeleted'] ?? m['deleted'] ?? false;
        print("ID: $id | Sender: $senderId | isDeleted: $isDel | Content: $content");
      }
    }
  }
}
