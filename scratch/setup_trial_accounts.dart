import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  
  print("=== STEP 1: Logging in as Trial Coach ===");
  final coachLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_coach_100@test.com", "password": "Password123!"}),
  );

  if (coachLoginRes.statusCode != 200 && coachLoginRes.statusCode != 201) {
    print("❌ Failed to login as Trial Coach: ${coachLoginRes.body}");
    return;
  }

  final coachLoginData = jsonDecode(coachLoginRes.body);
  final coachToken = coachLoginData['access_token'] ?? coachLoginData['data']?['accessToken'] ?? coachLoginData['token'] ?? coachLoginData['accessToken'];
  final coachUser = coachLoginData['user'] ?? coachLoginData['data']?['user'] ?? {};
  final coachId = coachUser['_id'] ?? coachUser['id'] ?? '6a069c8e668cf282b93545bb';
  print("✅ Coach logged in successfully. ID: $coachId");

  print("\n=== STEP 2: Creating/Updating Coach Profile ===");
  final profileBody = {
    "bio": "Expert Fitness & Nutrition Coach with over 8 years of experience helping clients achieve their dream physique.",
    "specialties": ["Weight Loss", "Muscle Gain", "Strength Training"],
    "experienceYears": 8,
    "certifications": ["ISSA Certified Personal Trainer", "Precision Nutrition Level 1"],
    "socialLinks": {"instagram": "https://instagram.com/fitglow_coach"}
  };

  var profileRes = await http.post(
    Uri.parse('$baseUrl/coach-profile'),
    headers: {
      'Authorization': 'Bearer $coachToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(profileBody),
  );

  print("Create Profile Status: ${profileRes.statusCode}");
  print("Create Profile Body: ${profileRes.body}");

  if (profileRes.statusCode == 409) {
    print("⚠️ Profile already exists. Updating profile instead...");
    profileRes = await http.put(
      Uri.parse('$baseUrl/coach-profile'),
      headers: {
        'Authorization': 'Bearer $coachToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profileBody),
    );
    print("Update Profile Status: ${profileRes.statusCode}");
    print("Update Profile Body: ${profileRes.body}");
  }

  print("\n=== STEP 3: Logging in as Trial Client ===");
  final clientLoginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "trial_client_100@test.com", "password": "Password123!"}),
  );

  if (clientLoginRes.statusCode != 200 && clientLoginRes.statusCode != 201) {
    print("❌ Failed to login as Trial Client: ${clientLoginRes.body}");
    return;
  }

  final clientLoginData = jsonDecode(clientLoginRes.body);
  final clientToken = clientLoginData['access_token'] ?? clientLoginData['data']?['accessToken'] ?? clientLoginData['token'] ?? clientLoginData['accessToken'];
  print("✅ Client logged in successfully.");

  print("\n=== STEP 4: Sending Coach Request from Client ===");
  final requestBody = {
    "coachId": coachId,
    "message": "Hi Coach! I would love to start my fitness journey with you.",
    "trainingType": "online"
  };

  final requestRes = await http.post(
    Uri.parse('$baseUrl/coach-client/request'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );

  print("Send Request Status: ${requestRes.statusCode}");
  print("Send Request Body: ${requestRes.body}");

  print("\n=== STEP 5: Coach Checking Pending Requests & Accepting ===");
  final pendingRes = await http.get(
    Uri.parse('$baseUrl/coach-client/pending-requests'),
    headers: {
      'Authorization': 'Bearer $coachToken',
      'Content-Type': 'application/json',
    },
  );

  print("Pending Requests Status: ${pendingRes.statusCode}");
  print("Pending Requests Body: ${pendingRes.body}");

  if (pendingRes.statusCode == 200 || pendingRes.statusCode == 201) {
    final List<dynamic> requests = jsonDecode(pendingRes.body);
    if (requests.isEmpty) {
      print("⚠️ No pending requests found. Checking if client is already in My Clients...");
      final clientsRes = await http.get(
        Uri.parse('$baseUrl/coach-client/my-clients'),
        headers: {
          'Authorization': 'Bearer $coachToken',
          'Content-Type': 'application/json',
        },
      );
      print("My Clients Status: ${clientsRes.statusCode}");
      print("My Clients Body: ${clientsRes.body}");
    } else {
      for (var req in requests) {
        final reqId = req['_id'] ?? req['id'];
        final clientName = req['client']?['firstName'] ?? 'Client';
        print("📌 Found pending request $reqId from $clientName. Accepting...");
        
        final acceptRes = await http.put(
          Uri.parse('$baseUrl/coach-client/request/$reqId/respond'),
          headers: {
            'Authorization': 'Bearer $coachToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"status": "accepted"}),
        );
        print("Accept Request Status: ${acceptRes.statusCode}");
        print("Accept Request Body: ${acceptRes.body}");
      }
    }
  }

  print("\n=== SUCCESS: Trial Accounts Fully Registered & Linked! ===");
}
