import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  const clientEmail = "trial_client_416518@test.com";

  print("=== STEP 1: Logging in as New Client ($clientEmail) ===");
  final clientLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": clientEmail, "password": "Password123!"}),
  );
  final clientData = jsonDecode(clientLoginRes.body);
  final clientToken = clientData['access_token'] ?? clientData['data']?['accessToken'] ?? clientData['token'] ?? '';

  const coachUserId = '6a069c8e668cf282b93545bb';

  print("\n=== STEP 2: Client sending Coach Request using Coach User ID ($coachUserId) ===");
  final reqRes = await http.post(
    Uri.parse('$baseUrl/coach-client/request'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'coachId': coachUserId,
      'message': 'Hi Coach! I want to train with you using User ID.',
      'trainingType': 'online',
    }),
  );
  print("Request Status: ${reqRes.statusCode}");
  print("Request Body: ${reqRes.body}");

  String reqId = '';
  if (reqRes.statusCode == 200 || reqRes.statusCode == 201) {
    final reqData = jsonDecode(reqRes.body);
    reqId = reqData['_id'] ?? reqData['id'] ?? '';
  } else {
    print("Checking pending requests...");
    final pendingRes = await http.get(
      Uri.parse('$baseUrl/coach-client/my-requests'),
      headers: {
        'Authorization': 'Bearer $clientToken',
        'Content-Type': 'application/json',
      },
    );
    final pendingList = jsonDecode(pendingRes.body) as List;
    if (pendingList.isNotEmpty) {
      reqId = pendingList.last['_id'] ?? pendingList.last['id'] ?? '';
    }
  }

  print("\n=== STEP 3: Logging in as Trial Coach ===");
  final coachLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_coach_100@test.com", "password": "Password123!"}),
  );
  final coachData = jsonDecode(coachLoginRes.body);
  final coachToken = coachData['access_token'] ?? coachData['data']?['accessToken'] ?? coachData['token'] ?? '';

  if (reqId.isNotEmpty) {
    print("\n=== STEP 4: Coach Accepting Request ($reqId) ===");
    final acceptRes = await http.put(
      Uri.parse('$baseUrl/coach-client/request/$reqId/respond'),
      headers: {
        'Authorization': 'Bearer $coachToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': 'accepted'}),
    );
    print("Accept Status: ${acceptRes.statusCode}");
    print("Accept Body: ${acceptRes.body}");
  } else {
    print("No pending request ID found to accept.");
  }

  print("\n=== STEP 5: Verifying Client My Coach ===");
  final myCoachRes = await http.get(
    Uri.parse('$baseUrl/coach-client/my-coach'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );
  print("My Coach Status: ${myCoachRes.statusCode}");
  print("My Coach Body: ${myCoachRes.body}");
}
