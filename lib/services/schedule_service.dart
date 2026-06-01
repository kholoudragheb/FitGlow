import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/time_slot_model.dart';
import '../models/session_model.dart';
import '../models/coach_calendar_model.dart';
import '../models/schedule_stats_model.dart';
import '../utils/token_storage.dart';

class ScheduleService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  Future<TimeSlotModel> createTimeSlot({required Map<String, dynamic> body}) async {
    final url = Uri.parse('$baseUrl/schedule');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Creating time slot...");
      print("Body: $body");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Create Time Slot Status: ${response.statusCode}");
        print("Create Time Slot Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TimeSlotModel.fromJson(data['slot'] ?? data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to create time slot (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in createTimeSlot: $e");
      rethrow;
    }
  }

  Future<List<TimeSlotModel>> getMyTimeSlots() async {
    final url = Uri.parse('$baseUrl/schedule/slots/my');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching my time slots...");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get My Time Slots Status: ${response.statusCode}");
        print("Get My Time Slots Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        List<dynamic> slotsList = [];
        if (decodedData is List) {
          slotsList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('slots')) {
          slotsList = decodedData['slots'];
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          slotsList = decodedData['data'];
        }

        return slotsList.map((slot) => TimeSlotModel.fromJson(slot)).toList();
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load time slots (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getMyTimeSlots: $e");
      rethrow;
    }
  }

  Future<bool> deleteTimeSlot({required String slotId}) async {
    final url = Uri.parse('$baseUrl/schedule/slots/$slotId');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Deleting time slot... ID: $slotId");
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Delete Time Slot Status: ${response.statusCode}");
        print("Delete Time Slot Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        String errorMsg = 'Failed to delete time slot (${response.statusCode})';
        try {
          final data = jsonDecode(response.body);
          errorMsg = data['message'] ?? errorMsg;
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (kDebugMode) print("Error in deleteTimeSlot: $e");
      rethrow;
    }
  }

  Future<List<TimeSlotModel>> getCoachAvailability({
    required String coachId,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse('$baseUrl/schedule/availability/$coachId?startDate=$startDate&endDate=$endDate');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching coach availability...");
      print("Coach: $coachId, Range: $startDate to $endDate");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get Coach Availability Status: ${response.statusCode}");
        print("Get Coach Availability Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        List<dynamic> slotsList = [];
        if (decodedData is List) {
          slotsList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('availability')) {
          slotsList = decodedData['availability'];
        } else if (decodedData is Map && decodedData.containsKey('slots')) {
          slotsList = decodedData['slots'];
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          slotsList = decodedData['data'];
        }

        return slotsList.map((slot) => TimeSlotModel.fromJson(slot)).toList();
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load availability (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getCoachAvailability: $e");
      rethrow;
    }
  }

  Future<SessionModel> bookSession({required Map<String, dynamic> body}) async {
    final url = Uri.parse('$baseUrl/schedule/sessions/book');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Booking session...");
      print("Body: $body");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Book Session Status: ${response.statusCode}");
        print("Book Session Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SessionModel.fromJson(data['session'] ?? data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to book session (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in bookSession: $e");
      rethrow;
    }
  }

  Future<List<SessionModel>> getMySessions() async {
    final url = Uri.parse('$baseUrl/schedule/sessions/my');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching my sessions...");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get My Sessions Status: ${response.statusCode}");
        print("Get My Sessions Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        List<dynamic> sessionsList = [];
        if (decodedData is List) {
          sessionsList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('sessions')) {
          sessionsList = decodedData['sessions'];
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          sessionsList = decodedData['data'];
        }

        return sessionsList.map((session) => SessionModel.fromJson(session)).toList();
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load sessions (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getMySessions: $e");
      rethrow;
    }
  }

  Future<SessionModel> getSessionById({required String sessionId}) async {
    final url = Uri.parse('$baseUrl/schedule/sessions/$sessionId');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching session details for ID: $sessionId...");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get Session By ID Status: ${response.statusCode}");
        print("Get Session By ID Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return SessionModel.fromJson(decodedData['session'] ?? decodedData['data'] ?? decodedData);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load session details (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getSessionById: $e");
      rethrow;
    }
  }

  Future<bool> updateSessionStatus({required String sessionId, required String status}) async {
    final url = Uri.parse('$baseUrl/schedule/sessions/$sessionId/status');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Updating session status... ID: $sessionId, Status: $status");
    }

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Update Session Status Result: ${response.statusCode}");
        print("Update Session Status Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update session status (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in updateSessionStatus: $e");
      rethrow;
    }
  }

  Future<bool> addSessionNotes({required String sessionId, required String notes}) async {
    final url = Uri.parse('$baseUrl/schedule/sessions/$sessionId/notes');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Adding session notes... ID: $sessionId");
    }

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'notes': notes}),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Add Session Notes Result: ${response.statusCode}");
        print("Add Session Notes Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to add session notes (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in addSessionNotes: $e");
      rethrow;
    }
  }

  Future<SessionModel> updateSession({
    required String sessionId,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('$baseUrl/schedule/sessions/$sessionId');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Updating session...");
      print("ID: $sessionId");
      print("Body: $body");
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Update Session Status: ${response.statusCode}");
        print("Update Session Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SessionModel.fromJson(data['session'] ?? data['data'] ?? data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update session (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in updateSession: $e");
      rethrow;
    }
  }

  Future<SessionModel> cancelSession({
    required String sessionId,
    required String reason,
  }) async {
    final url = Uri.parse('$baseUrl/schedule/sessions/$sessionId/cancel');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Canceling session...");
      print("ID: $sessionId");
      print("Reason: $reason");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Cancel Session Status: ${response.statusCode}");
        print("Cancel Session Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SessionModel.fromJson(data['session'] ?? data['data'] ?? data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to cancel session (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in cancelSession: $e");
      rethrow;
    }
  }

  Future<ScheduleStatsModel> getScheduleStats() async {
    final url = Uri.parse('$baseUrl/schedule/stats');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching schedule stats...");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get Schedule Stats Status: ${response.statusCode}");
        print("Get Schedule Stats Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return ScheduleStatsModel.fromJson(decodedData['stats'] ?? decodedData['data'] ?? decodedData);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load schedule stats (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getScheduleStats: $e");
      rethrow;
    }
  }

  Future<CoachCalendarModel> getCoachCalendar({
    required int month,
    required int year,
  }) async {
    final url = Uri.parse('$baseUrl/schedule/calendar?month=$month&year=$year');
    String? token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching coach calendar...");
      print("Month: $month, Year: $year");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Get Coach Calendar Status: ${response.statusCode}");
        print("Get Coach Calendar Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return CoachCalendarModel.fromJson(decodedData['calendar'] ?? decodedData['data'] ?? decodedData);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to load calendar (${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) print("Error in getCoachCalendar: $e");
      rethrow;
    }
  }
}
