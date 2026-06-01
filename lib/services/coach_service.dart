import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/coach_model.dart';
import '../models/coach_details_model.dart';
import '../models/coach_profile_model.dart';
import '../models/coach_request_model.dart';
import '../models/client_request_model.dart';
import '../models/my_coach_model.dart';
import '../models/my_client_model.dart';
import '../models/pending_request_model.dart';
import '../models/client_details_model.dart';
import '../models/coach_stats_model.dart';
import '../utils/token_storage.dart';

class CoachService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<List<Coach>> getCoaches({
    String? specialty,
    double? minRating,
    bool? verifiedOnly,
    String? search,
  }) async {
    print("Fetching coaches...");
    print("Filters:");
    final filters = {
      "specialty": specialty,
      "minRating": minRating,
      "verifiedOnly": verifiedOnly,
      "search": search
    };
    print(filters);

    // Build query parameters
    final Map<String, String> queryParams = {};
    if (specialty != null && specialty.isNotEmpty && specialty != 'All') {
      queryParams['specialty'] = specialty;
    }
    if (minRating != null && minRating > 0) {
      queryParams['minRating'] = minRating.toString();
    }
    if (verifiedOnly == true) {
      queryParams['verifiedOnly'] = 'true';
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('$baseUrl/coach-profile').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Response:");
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        final coaches = data.map((json) => Coach.fromJson(json)).toList();
        print("Coach count:");
        print(coaches.length);
        return coaches;
      } else {
        throw Exception('Failed to load coaches: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error fetching coaches: $e');
      throw Exception('Failed to load coaches');
    }
  }

  Future<CoachDetailsModel> getCoachById(String coachId) async {
    print("Opening coach details:");
    print(coachId);
    final uri = Uri.parse('$baseUrl/coach-profile/$coachId');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Coach response:");
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CoachDetailsModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Coach profile not found');
      } else {
        throw Exception('Failed to load coach profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error fetching coach details: $e');
      throw Exception('Failed to load coach profile');
    }
  }

  Future<CoachProfileModel> createCoachProfile({
    required String bio,
    required List<String> specialties,
    required int experienceYears,
    required List<String> certifications,
    Map<String, dynamic>? socialLinks,
  }) async {
    final Map<String, dynamic> requestBody = {
      "bio": bio,
      "specialties": specialties,
      "experienceYears": experienceYears,
      "certifications": certifications,
      "socialLinks": socialLinks ?? {},
    };

    print("Creating coach profile...");
    print(requestBody);

    final uri = Uri.parse('$baseUrl/coach-profile');
    String? token = await TokenStorage.getAccessToken();

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 10));

    print("Response:");
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CoachProfileModel.fromJson(data);
    } else if (response.statusCode == 400) {
      throw Exception('Validation error');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 409) {
      throw Exception('Profile already exists');
    } else {
      throw Exception('Server error');
    }
  }

  Future<CoachProfileModel> getMyCoachProfile() async {
    print("Fetching my coach profile...");
    
    final uri = Uri.parse('$baseUrl/coach-profile/me');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CoachProfileModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        throw Exception('Profile not found');
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      debugPrint('[CoachService] Error fetching my profile: $e');
      if (e.toString().contains('Profile not found')) {
        rethrow; // Maintain specific error for routing
      }
      throw Exception('Failed to load coach profile');
    }
  }

  Future<CoachProfileModel> updateCoachProfile({
    required String bio,
    required List<String> specialties,
    required int experienceYears,
    required List<String> certifications,
  }) async {
    final Map<String, dynamic> requestBody = {
      "bio": bio,
      "specialties": specialties,
      "experienceYears": experienceYears,
      "certifications": certifications,
    };

    print("Updating coach profile...");
    print(requestBody);

    final uri = Uri.parse('$baseUrl/coach-profile');
    String? token = await TokenStorage.getAccessToken();

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 10));

    print("Updated response:");
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CoachProfileModel.fromJson(data);
    } else if (response.statusCode == 400) {
      throw Exception('Invalid data');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Profile not found');
    } else {
      throw Exception('Server error');
    }
  }

  Future<CoachRequestModel> sendCoachRequest({
    required String coachId,
    required String message,
    required String trainingType,
  }) async {
    final Map<String, dynamic> requestBody = {
      "coachId": coachId,
      "message": message,
      "trainingType": trainingType,
    };

    print("Sending coach request...");
    print(requestBody);

    final uri = Uri.parse('$baseUrl/coach-client/request');
    String? token = await TokenStorage.getAccessToken();

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 10));

    print("Response:");
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CoachRequestModel.fromJson(data);
    } else if (response.statusCode == 400) {
      throw Exception('Invalid request');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Coach not found');
    } else if (response.statusCode == 409) {
      throw Exception('Already requested');
    } else {
      throw Exception('Server error');
    }
  }

  Future<List<ClientRequestModel>> getMyRequests() async {
    print("Fetching client requests...");
    
    final uri = Uri.parse('$baseUrl/coach-client/my-requests');
    String? token = await TokenStorage.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    print("Response:");
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ClientRequestModel.fromJson(json)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to load requests');
    }
  }

  Future<ClientRequestModel> cancelCoachRequest(String requestId) async {
    print("Canceling coach request: $requestId");

    final uri = Uri.parse('$baseUrl/coach-client/request/$requestId');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Response:");
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClientRequestModel.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 403) {
        throw Exception('Not allowed to cancel this request');
      } else if (response.statusCode == 404) {
        throw Exception('Request not found');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error canceling request: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<MyCoachModel?> getMyCoach() async {
    print("Fetching my coach...");
    
    final uri = Uri.parse('$baseUrl/coach-client/my-coach');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        var coachModel = MyCoachModel.fromJson(data);
        
        try {
          if (coachModel.userId.isNotEmpty) {
            final profileUri = Uri.parse('$baseUrl/coach-profile?userId=${coachModel.userId}');
            final profileRes = await http.get(
              profileUri,
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
            ).timeout(const Duration(seconds: 5));

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
        } catch (e) {
          debugPrint('[CoachService] Error enriching coach profile: $e');
        }

        return coachModel;
      } else if (response.statusCode == 404) {
        // No coach assigned
        return null;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load my coach: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error fetching my coach: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<List<PendingRequestModel>> getPendingRequests() async {
    print("Fetching pending requests...");
    
    final uri = Uri.parse('$baseUrl/coach-client/pending-requests');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Pending requests response Code: ${response.statusCode}");
      print("Pending requests response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        final requests = data.map((json) => PendingRequestModel.fromJson(json)).toList();
        
        for (var req in requests) {
          print("Parsed client: ${req.client.fullName} (${req.client.email})");
        }
        
        return requests;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load pending requests: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error fetching pending requests: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<List<MyClientModel>> getMyClients() async {
    print("Fetching my clients...");
    
    final uri = Uri.parse('$baseUrl/coach-client/my-clients');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MyClientModel.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load clients: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error fetching my clients: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<PendingRequestModel> respondToRequest({
    required String requestId,
    required String status,
  }) async {
    print("Responding to request: $requestId with status: $status");

    final uri = Uri.parse('$baseUrl/coach-client/request/$requestId/respond');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"status": status}),
      ).timeout(const Duration(seconds: 10));

      print("Respond To Request Code: ${response.statusCode}");
      print("Respond To Request Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PendingRequestModel.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request data');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 403) {
        throw Exception('Not authorized to respond to this request');
      } else if (response.statusCode == 404) {
        throw Exception('Request not found');
      } else if (response.statusCode == 409) {
        throw Exception('Already responded to this request');
      } else {
        throw Exception('Failed to respond: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error responding to request: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<ClientDetailsModel> getClientDetails(String clientId) async {
    print("Fetching client details for: $clientId");

    final uri = Uri.parse('$baseUrl/coach-client/client/$clientId');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Client Details Response Code: ${response.statusCode}");
      print("Client Details Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClientDetailsModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 403) {
        throw Exception('Not authorized to view this client');
      } else if (response.statusCode == 404) {
        throw Exception('Client details not found');
      } else {
        throw Exception('Failed to load client details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error fetching client details: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<ClientDetailsModel> updateClientDetails({
    required String clientId,
    required Map<String, dynamic> body,
  }) async {
    print("Updating client details for: $clientId");
    print("Body: $body");

    final uri = Uri.parse('$baseUrl/coach-client/client/$clientId');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      print("Update Client Response Code: ${response.statusCode}");
      print("Update Client Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClientDetailsModel.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid data provided');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 403) {
        throw Exception('Not authorized to update this client');
      } else if (response.statusCode == 404) {
        throw Exception('Client not found');
      } else {
        throw Exception('Failed to update client: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error updating client details: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<ClientDetailsModel> removeClient(String clientId) async {
    print("Removing client: $clientId");

    final uri = Uri.parse('$baseUrl/coach-client/client/$clientId');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Remove Client Response Code: ${response.statusCode}");
      print("Remove Client Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClientDetailsModel.fromJson(data);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 403) {
        throw Exception('Not authorized to remove this client');
      } else if (response.statusCode == 404) {
        throw Exception('Client not found');
      } else {
        throw Exception('Failed to remove client: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error removing client: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  Future<CoachStatsModel> getCoachStats() async {
    print("Fetching coach stats...");

    final uri = Uri.parse('$baseUrl/coach-client/stats');
    String? token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Coach Stats Response Code: ${response.statusCode}");
      print("Coach Stats Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CoachStatsModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CoachService] Error fetching coach stats: $e');
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }
}
