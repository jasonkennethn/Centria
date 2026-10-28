import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  /// Root host for API (Render in production/release, localhost in debug web/desktop, 10.0.2.2 in Android emulator)
  static String get apiHost {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      final clean = envUrl.endsWith('/') ? envUrl.substring(0, envUrl.length - 1) : envUrl;
      return clean.replaceAll('/api/auth', '').replaceAll('/api/v1', '');
    }

    if (!kDebugMode) {
      return 'https://centria-enterprise.onrender.com';
    }

    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    return 'http://10.0.2.2:8000';
  }

  static String get authUrl => '$apiHost/api/auth';
  static String get apiV1Url => '$apiHost/api/v1';

  // Backward compatibility alias for legacy callers
  static String get baseUrl => authUrl;

  // Active Company Tenant Context (can be passed via X-Company-ID header)
  static String? activeCompanyId;

  static Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (activeCompanyId != null && activeCompanyId!.isNotEmpty) {
      headers['X-Company-ID'] = activeCompanyId!;
    }
    return headers;
  }

  // --- AUTH ENDPOINTS ---

  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$authUrl/check-email/'),
            headers: _buildHeaders(),
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
            Uri.parse('$authUrl/login/'),
            headers: _buildHeaders(),
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
            Uri.parse('$authUrl/register/'),
            headers: _buildHeaders(),
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

  // --- ENTERPRISE API V1 ENDPOINTS ---

  /// GET /api/v1/overview/
  static Future<Map<String, dynamic>> getOverview() async {
    try {
      final res = await http
          .get(Uri.parse('$apiV1Url/overview/'), headers: _buildHeaders())
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      throw Exception('Overview fetch failed with code ${res.statusCode}');
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  /// GET /api/v1/tasks/
  static Future<List<Map<String, dynamic>>> getTasks({String? status}) async {
    try {
      final uri = status != null
          ? Uri.parse('$apiV1Url/tasks/?status=$status')
          : Uri.parse('$apiV1Url/tasks/');
      final res = await http.get(uri, headers: _buildHeaders()).timeout(_timeout);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// POST /api/v1/tasks/
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> data) async {
    final res = await http
        .post(
          Uri.parse('$apiV1Url/tasks/'),
          headers: _buildHeaders(),
          body: jsonEncode(data),
        )
        .timeout(_timeout);
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to create task: ${res.body}');
  }

  /// PATCH /api/v1/tasks/{id}/
  static Future<Map<String, dynamic>> updateTask(String taskId, Map<String, dynamic> data) async {
    final res = await http
        .patch(
          Uri.parse('$apiV1Url/tasks/$taskId/'),
          headers: _buildHeaders(),
          body: jsonEncode(data),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to update task: ${res.body}');
  }

  /// DELETE /api/v1/tasks/{id}/
  static Future<bool> deleteTask(String taskId) async {
    final res = await http
        .delete(Uri.parse('$apiV1Url/tasks/$taskId/'), headers: _buildHeaders())
        .timeout(_timeout);
    return res.statusCode == 204;
  }

  /// GET /api/v1/approvals/
  static Future<List<Map<String, dynamic>>> getApprovals({String? status}) async {
    try {
      final uri = status != null
          ? Uri.parse('$apiV1Url/approvals/?status=$status')
          : Uri.parse('$apiV1Url/approvals/');
      final res = await http.get(uri, headers: _buildHeaders()).timeout(_timeout);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// POST /api/v1/approvals/{id}/execute/
  static Future<Map<String, dynamic>> executeApproval(
    String approvalId, {
    String action = 'APPROVE',
    String? decisionNote,
  }) async {
    final res = await http
        .post(
          Uri.parse('$apiV1Url/approvals/$approvalId/execute/'),
          headers: _buildHeaders(),
          body: jsonEncode({
            'action': action,
            'decision_note': decisionNote ?? 'Biometric ratification completed via Director Secure Enclave.',
          }),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Approval execution failed: ${res.body}');
  }

  /// GET /api/v1/finance/
  static Future<Map<String, dynamic>> getFinance() async {
    try {
      final res = await http.get(Uri.parse('$apiV1Url/finance/'), headers: _buildHeaders()).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// GET /api/v1/statutory/
  static Future<Map<String, dynamic>> getStatutory() async {
    try {
      final res = await http.get(Uri.parse('$apiV1Url/statutory/'), headers: _buildHeaders()).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// GET /api/v1/integrations/
  static Future<Map<String, dynamic>> getIntegrations() async {
    try {
      final res = await http.get(Uri.parse('$apiV1Url/integrations/'), headers: _buildHeaders()).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// GET /api/v1/audit/
  static Future<List<Map<String, dynamic>>> getAudit() async {
    try {
      final res = await http.get(Uri.parse('$apiV1Url/audit/'), headers: _buildHeaders()).timeout(_timeout);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
