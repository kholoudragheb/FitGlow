import 'dart:convert';
import 'package:http/http.dart' as http;
import '../lib/models/my_coach_model.dart';

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

  print("\n=== STEP 2: Simulating CoachService().getMyCoach() enrichment ===");
  final myCoachRes = await http.get(
    Uri.parse('$baseUrl/coach-client/my-coach'),
    headers: {
      'Authorization': 'Bearer $clientToken',
      'Content-Type': 'application/json',
    },
  );

  if (myCoachRes.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(myCoachRes.body);
    var coachModel = MyCoachModel.fromJson(data);
    
    print("Before Enrichment: Bio=${coachModel.bio}, Specialties=${coachModel.specialties}, Image=${coachModel.imageUrl}");

    if (coachModel.userId.isNotEmpty) {
      final profileUri = Uri.parse('$baseUrl/coach-profile?userId=${coachModel.userId}');
      final profileRes = await http.get(
        profileUri,
        headers: {
          'Authorization': 'Bearer $clientToken',
          'Content-Type': 'application/json',
        },
      );

      if (profileRes.statusCode == 200) {
        final List<dynamic> profileList = jsonDecode(profileRes.body);
        final matchedProfiles = profileList.where((p) {
          if (p == null) return false;
          final u = p['userId'];
          if (u is Map) {
            final uid = u['_id']?.toString() ?? u['id']?.toString() ?? '';
            return uid == coachModel.userId;
          }
          return u?.toString() == coachModel.userId;
        }).toList();

        if (matchedProfiles.isNotEmpty) {
          final Map<String, dynamic> profileData = matchedProfiles.first;
          coachModel = coachModel.copyWith(
            bio: profileData['bio']?.toString() ?? coachModel.bio,
            specialties: profileData['specialties'] != null ? List<String>.from(profileData['specialties']) : coachModel.specialties,
            experienceYears: profileData['experienceYears'] ?? coachModel.experienceYears,
            certifications: profileData['certifications'] != null ? List<String>.from(profileData['certifications']) : coachModel.certifications,
            averageRating: (profileData['averageRating'] ?? profileData['rating'] ?? coachModel.averageRating).toDouble(),
            totalReviews: profileData['totalReviews'] ?? coachModel.totalReviews,
            isVerified: profileData['isVerified'] ?? profileData['verified'] ?? coachModel.isVerified,
            imageUrl: MyCoachModel.parseImageUrl(profileData, profileData) ?? coachModel.imageUrl,
          );
        }
      }
    }

    print("\n=== AFTER ENRICHMENT ===");
    print("Enriched Coach Name: ${coachModel.fullName}");
    print("Enriched Coach Bio: ${coachModel.bio}");
    print("Enriched Coach Specialties: ${coachModel.specialties}");
    print("Enriched Coach Experience: ${coachModel.experienceYears} years");
    print("Enriched Coach Certifications: ${coachModel.certifications}");
    print("Enriched Coach Image URL: ${coachModel.imageUrl}");
    print("Enriched Coach Verified: ${coachModel.isVerified}");
  } else {
    print("My Coach fetch failed: ${myCoachRes.statusCode}");
  }
}
