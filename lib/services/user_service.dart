import 'dart:convert';
import '../models/user_model.dart';
import '../models/update_profile_model.dart';
import '../models/saved_items_model.dart';
import '../services/authenticated_client.dart';
import '../main.dart'; // To get navigatorKey

class UserService {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  final AuthenticatedClient _client = AuthenticatedClient(navigatorKey: navigatorKey);

  /// Fetches the profile of the currently authenticated user.
  /// Returns the [UserModel] on success, or throws an exception on failure.
  Future<UserModel> getProfile() async {
    final url = Uri.parse('$baseUrl/users/me');

    try {
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return UserModel.fromJson(jsonResponse);
      } else {
        // You might want a more specific error handling here
        throw Exception('Failed to load profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching profile: $e');
    }
  }

  /// Updates the profile of the currently authenticated user.
  /// Returns an [UpdateProfileResponse] containing the result.
  Future<UpdateProfileResponse> updateProfile(UpdateProfileRequest request) async {
    final url = Uri.parse('$baseUrl/users/me');
    final body = jsonEncode(request.toJson());

    print("Saving onboarding profile...");
    print("Request Body: $body");

    try {
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("Updated profile response status: ${response.statusCode}");
      print("Updated profile response body: ${response.body}");

      Map<String, dynamic> jsonResponse = {};
      if (response.body.isNotEmpty) {
        try {
          jsonResponse = jsonDecode(response.body);
        } catch (_) {}
      }

      return UpdateProfileResponse.fromJson(jsonResponse, response.statusCode);
    } catch (e) {
      return UpdateProfileResponse.withError('An error occurred: $e');
    }
  }

  /// Updates the profile of the currently authenticated user with specific fields.
  /// Returns the configured [UserModel] on success, or throws an exception on failure.
  Future<UserModel> updateProfileFields({
    required String firstName,
    required String lastName,
    required String gender,
    required int height,
    required int weight,
    required String fitnessGoal,
    required String fitnessLevel,
    required bool onboardingCompleted,
  }) async {
    final url = Uri.parse('$baseUrl/users/me');

    print("Sending update profile request:");
    print(firstName);
    print(height);
    print(weight);

    try {
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "gender": gender,
          "height": height,
          "weight": weight,
          "fitnessGoal": fitnessGoal,
          "fitnessLevel": fitnessLevel,
          "onboardingCompleted": onboardingCompleted,
        }),
      );

      print("Response:");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return UserModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to update profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while updating profile: $e');
    }
  }

  /// Fetches the saved items of the currently authenticated user.
  /// Returns [SavedItemsModel] on success, or throws an exception on failure.
  Future<SavedItemsModel> getSavedItems() async {
    final url = Uri.parse('$baseUrl/users/saved');

    try {
      final response = await _client.get(url);

      print("Saved Items Response:");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return SavedItemsModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load saved items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching saved items: $e');
    }
  }

  /// Saves a workout for the currently authenticated user.
  Future<void> saveWorkout(String workoutId) async {
    final url = Uri.parse('$baseUrl/users/saved/workouts/$workoutId');

    print("Saving workout with ID: $workoutId");

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("Save workout response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
      } else if (response.statusCode == 409) {
        throw Exception('Workout already saved');
      } else {
        throw Exception('Failed to save workout. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Removes a workout from the saved list for the currently authenticated user.
  Future<void> unsaveWorkout(String workoutId) async {
    final url = Uri.parse('$baseUrl/users/saved/workouts/$workoutId');

    print("Unsaving workout with ID: $workoutId");

    try {
      final response = await _client.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("Unsave workout response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
      } else if (response.statusCode == 404) {
        throw Exception('Workout not found in saved list');
      } else {
        throw Exception('Failed to unsave workout. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Saves a meal for the currently authenticated user.
  Future<void> saveMeal(String mealId) async {
    final url = Uri.parse('$baseUrl/users/saved/meals/$mealId');

    print("Saving meal with ID: $mealId");

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("Save meal response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
      } else if (response.statusCode == 409) {
        throw Exception('Meal already saved');
      } else {
        throw Exception('Failed to save meal. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Removes a meal from the saved list for the currently authenticated user.
  Future<void> unsaveMeal(String mealId) async {
    final url = Uri.parse('$baseUrl/users/saved/meals/$mealId');

    print("Unsaving meal with ID: $mealId");

    try {
      final response = await _client.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("Unsave meal response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
      } else if (response.statusCode == 404) {
        throw Exception('Meal not found in saved list');
      } else {
        throw Exception('Failed to unsave meal. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
