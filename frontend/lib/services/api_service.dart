import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      final clean = envUrl.endsWith('/') ? envUrl.substring(0, envUrl.length - 1) : envUrl;
      return clean.endsWith('/api/auth') ? clean : '$clean/api/auth';
    }

    // In release mode or production, use Render backend
    if (!kDebugMode) {
      return 'https://centria-enterprise.onrender.com/api/auth';
    }

    // In debug/dev mode:
    if (kIsWeb) {
      return 'http://localhost:8000/api/auth';
    }
    // Android emulator alias for host machine localhost
    return 'http://10.0.2.2:8000/api/auth';
  }

  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/check-email/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to verify email');
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('Unable to reach server. Please check your connection.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      }
      throw Exception(body['error'] ?? 'Invalid credentials');
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('Unable to reach server. Please check your connection.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'first_name': firstName,
              'last_name': lastName,
            }),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return body;
      }
      final errors = body['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final first = errors.values.first;
        final msg = first is List ? first.first : first.toString();
        throw Exception(msg);
      }
      throw Exception(body['error'] ?? 'Registration failed. Please try again.');
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('Unable to reach server. Please check your connection.');
      }
      rethrow;
    }
  }
}
