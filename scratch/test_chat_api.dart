import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final loginUrl = Uri.parse('https://exact-gwenette-fitglow-38dc47eb.koyeb.app/auth/login');
  final loginRes = await http.post(
    loginUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_coach_100@test.com", "password": "Password123!"}),
  );

  final loginData = jsonDecode(loginRes.body);
  final realToken = loginData['access_token'] ?? loginData['data']?['accessToken'] ?? loginData['token'] ?? loginData['accessToken'];

  final convsUrl = Uri.parse('https://exact-gwenette-fitglow-38dc47eb.koyeb.app/chat/conversations');
  final convsRes = await http.get(convsUrl, headers: {
    'Authorization': 'Bearer $realToken',
    'Content-Type': 'application/json',
  });

  String debugInfo = "Conversations Status: ${convsRes.statusCode}\nConversations Body: ${convsRes.body}\n\n";

  if (convsRes.statusCode == 200) {
    final decoded = jsonDecode(convsRes.body);
    List convs = decoded is List ? decoded : (decoded['conversations'] ?? decoded['data'] ?? []);
    if (convs.isNotEmpty) {
      final cid = convs[0]['_id'] ?? convs[0]['id'];
      debugInfo += "First CID: $cid\n\n";

      final detailUrl = Uri.parse('https://exact-gwenette-fitglow-38dc47eb.koyeb.app/chat/conversations/$cid');
      final detailRes = await http.get(detailUrl, headers: {
        'Authorization': 'Bearer $realToken',
        'Content-Type': 'application/json',
      });
      debugInfo += "Detail Status: ${detailRes.statusCode}\nDetail Body: ${detailRes.body}\n\n";

      final msgUrl = Uri.parse('https://exact-gwenette-fitglow-38dc47eb.koyeb.app/chat/conversations/$cid/messages?limit=50');
      final msgRes = await http.get(msgUrl, headers: {
        'Authorization': 'Bearer $realToken',
        'Content-Type': 'application/json',
      });
      debugInfo += "Messages Status: ${msgRes.statusCode}\nMessages Body: ${msgRes.body}\n\n";
    }
  }

  File('scratch/chat_debug.txt').writeAsStringSync(debugInfo);
  print("Debug info written to scratch/chat_debug.txt");
}
