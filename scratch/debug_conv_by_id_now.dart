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

  print("\n=== STEP 2: Fetching GET /chat/conversations/6a069cb0668cf282b93545c3 ===");
  final convRes = await http.get(
    Uri.parse('$baseUrl/chat/conversations/6a069cb0668cf282b93545c3'),
    headers: {'Authorization': 'Bearer $clientToken', 'Content-Type': 'application/json'},
  );
  print("Status: ${convRes.statusCode}");
  
  if (convRes.statusCode == 200) {
    final decoded = jsonDecode(convRes.body);
    final conv = decoded['conversation'] ?? decoded['data'] ?? decoded;
    final List msgs = conv['messages'] ?? [];
    print("Found ${msgs.length} messages in conversation object.\n");
    for (var m in msgs) {
      final id = m['_id'] ?? m['id'];
      final content = m['content'] ?? m['text'];
      final isDel = m['isDeleted'] ?? m['deleted'] ?? false;
      print("ID: $id | isDeleted: $isDel | Content: $content");
    }
  }
}
