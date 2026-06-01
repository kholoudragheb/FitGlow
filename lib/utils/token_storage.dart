import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _userFirstNameKey = 'user_first_name';
  static const String _userLastNameKey = 'user_last_name';
  static const String _userIdKey = 'user_id';


  static Future<void> saveTokensAndUser({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String email,
    required String firstName,
    required String lastName,
    required String userId,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userFirstNameKey, firstName);
    await prefs.setString(_userLastNameKey, lastName);
    await prefs.setString(_userIdKey, userId);
  }


  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userFirstNameKey);
    await prefs.remove(_userLastNameKey);
    await prefs.remove(_userIdKey);
  }


  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getUserFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userFirstNameKey);
  }

  static Future<String?> getUserLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userLastNameKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}


