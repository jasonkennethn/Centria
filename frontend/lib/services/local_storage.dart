import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple local storage wrapper around SharedPreferences.
/// Stores user session data for offline access.
class LocalStorage {
  static const _keyUser = 'centria_user';
  static const _keyLoggedIn = 'centria_logged_in';

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user));
    await prefs.setBool(_keyLoggedIn, true);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.setBool(_keyLoggedIn, false);
  }
}
