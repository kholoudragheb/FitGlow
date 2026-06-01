import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/chat_service.dart';
import '../lib/utils/token_storage.dart';

void main() {
  test('Verify ChatService getConversations Fallback Recovery', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

    print("=== STEP 1: Logging in as Trial Client ===");
    final clientLoginRes = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": "trial_client_100@test.com", "password": "Password123!"}),
    );
    final clientData = jsonDecode(clientLoginRes.body);
    final clientToken = clientData['access_token'] ?? clientData['data']?['accessToken'] ?? clientData['token'];
    await TokenStorage.saveTokens(accessToken: clientToken);

    print("\n=== STEP 2: Testing ChatService().getConversations() with Fallback Recovery ===");
    try {
      final chatService = ChatService();
      final convs = await chatService.getConversations();
      print("SUCCESS!!! Recovered ${convs.length} conversations!");
      if (convs.isNotEmpty) {
        final c = convs.first;
        print("Recovered Conv ID: ${c.id}");
        print("Recovered Conv Last Message: ${c.lastMessage}");
        print("Recovered Conv Participants: ${c.participants.map((p) => p.firstName).toList()}");
      }
    } catch (e) {
      print("FAILED: $e");
    }
  });
}
