import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Configurable base URLs via --dart-define=API_BASE_URL=... and --dart-define=WS_BASE_URL=...
  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _envWsBaseUrl = String.fromEnvironment('WS_BASE_URL');

  static const String _defaultProductionUrl = 'https://centria-enterprise.onrender.com';
  static const String _defaultLocalUrl = 'http://127.0.0.1:8000';

  static String? _customBaseUrl;
  static set baseUrl(String url) => _customBaseUrl = url;

  // Dynamic Base URL: on web, if accessed from localhost or 127.0.0.1, use local backend
  static String get baseUrl {
    if (_customBaseUrl != null) return _customBaseUrl!;
    if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;

    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0' || host.isEmpty) {
        return _defaultLocalUrl;
      }
    }
    return kReleaseMode ? _defaultProductionUrl : _defaultLocalUrl;
  }

  // Hardware-backed secure storage for sensitive authentication credentials
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;

  static dynamic _parseJson(http.Response res) {
    if (res.body.isEmpty) return null;
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    try {
      _cachedAccessToken = await _secureStorage.read(key: 'access_token');
      if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
        return _cachedAccessToken;
      }
    } catch (_) {}

    // Migration fallback from SharedPreferences if previously stored
    try {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString('access_token');
      if (legacy != null && legacy.isNotEmpty) {
        _cachedAccessToken = legacy;
        await _secureStorage.write(key: 'access_token', value: legacy);
        await prefs.remove('access_token');
      }
    } catch (_) {}

    return _cachedAccessToken;
  }

  static Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    try {
      _cachedRefreshToken = await _secureStorage.read(key: 'refresh_token');
      if (_cachedRefreshToken != null && _cachedRefreshToken!.isNotEmpty) {
        return _cachedRefreshToken;
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString('refresh_token');
      if (legacy != null && legacy.isNotEmpty) {
        _cachedRefreshToken = legacy;
        await _secureStorage.write(key: 'refresh_token', value: legacy);
        await prefs.remove('refresh_token');
      }
    } catch (_) {}

    return _cachedRefreshToken;
  }

  static Future<void> saveTokens({required String access, required String refresh}) async {
    _cachedAccessToken = access;
    _cachedRefreshToken = refresh;
    try {
      await _secureStorage.write(key: 'access_token', value: access);
      await _secureStorage.write(key: 'refresh_token', value: refresh);
    } catch (_) {}

    // Ensure sensitive tokens are completely removed from unencrypted SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    } catch (_) {}
  }

  static Future<void> clearTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    try {
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
    } catch (_) {}
  }

  static Future<Map<String, String>> _headers({bool needsAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (needsAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- Auth APIs ---

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/login/');
      final res = await http.post(
        url,
        headers: await _headers(needsAuth: false),
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );
      final data = _parseJson(res);
      if (res.statusCode == 200 && data is Map<String, dynamic>) {
        await saveTokens(access: data['access'], refresh: data['refresh']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        return {'success': true, 'data': data};
      } else {
        final err = (data is Map)
            ? (data['detail'] ?? data['error'] ?? 'Sign in failed. Check your credentials.')
            : 'Server returned code ${res.statusCode}. Please verify backend is running.';
        return {'success': false, 'error': err.toString()};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error. Ensure the Centria backend server is running on $baseUrl',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String companyName,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/register/');
      final res = await http.post(
        url,
        headers: await _headers(needsAuth: false),
        body: jsonEncode({
          'company_name': companyName.trim(),
          'full_name': fullName.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );
      final data = _parseJson(res);
      if (res.statusCode == 201 && data is Map<String, dynamic>) {
        await saveTokens(access: data['access'], refresh: data['refresh']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        return {'success': true, 'data': data};
      } else {
        final err = (data is Map)
            ? (data['email'] ?? data['error'] ?? data['detail'] ?? 'Registration failed.')
            : 'Server returned code ${res.statusCode}.';
        return {'success': false, 'error': err is List ? err.first : err.toString()};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error. Ensure backend is running on $baseUrl',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/forgot-password/');
      final res = await http.post(
        url,
        headers: await _headers(needsAuth: false),
        body: jsonEncode({'email': email.trim()}),
      );
      final data = _parseJson(res);
      return {'success': res.statusCode == 200, 'data': data};
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/reset-password/');
      final res = await http.post(
        url,
        headers: await _headers(needsAuth: false),
        body: jsonEncode({
          'email': email.trim(),
          'otp_code': otpCode.trim(),
          'new_password': newPassword,
        }),
      );
      final data = _parseJson(res);
      if (res.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        final err = (data is Map) ? (data['error'] ?? data['detail'] ?? 'Reset failed.') : 'Reset failed.';
        return {'success': false, 'error': err.toString()};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/me/');
      final res = await http.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('getMe error: $e');
    }
    return null;
  }

  // --- Dashboard & Projects ---

  static Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final url = Uri.parse('$baseUrl/api/projects/dashboard/');
      final res = await http.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('getDashboard error: $e');
    }
    return null;
  }

  static Future<List<dynamic>> getProjects() async {
    try {
      final url = Uri.parse('$baseUrl/api/projects/items/');
      final res = await http.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data is List ? data : (data['results'] ?? []);
      }
    } catch (e) {
      debugPrint('getProjects error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> createProject({
    required String name,
    required String key,
    String description = '',
  }) async {
    final url = Uri.parse('$baseUrl/api/projects/items/');
    final res = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({'name': name, 'key': key.toUpperCase(), 'description': description}),
    );
    return res.statusCode == 201 ? jsonDecode(res.body) : null;
  }

  static Future<List<dynamic>> getTasks({String? projectId, String? status}) async {
    try {
      String path = '$baseUrl/api/projects/tasks/?';
      if (projectId != null) path += 'project=$projectId&';
      if (status != null) path += 'status=$status&';
      final res = await http.get(Uri.parse(path), headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data is List ? data : (data['results'] ?? []);
      }
    } catch (e) {
      debugPrint('getTasks error: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> createTask({
    required String projectId,
    required String title,
    String description = '',
    String priority = 'medium',
    String taskType = 'task',
  }) async {
    final url = Uri.parse('$baseUrl/api/projects/tasks/');
    final res = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'project': projectId,
        'title': title,
        'description': description,
        'priority': priority,
        'task_type': taskType,
      }),
    );
    return res.statusCode == 201 ? jsonDecode(res.body) : null;
  }

  static Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    try {
      final url = Uri.parse('$baseUrl/api/projects/tasks/$taskId/');
      final res = await http.patch(
        url,
        headers: await _headers(),
        body: jsonEncode({'status': newStatus}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Documents & RAG ---

  static Future<List<dynamic>> getDocuments() async {
    try {
      final url = Uri.parse('$baseUrl/api/documents/items/');
      final res = await http.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data is List ? data : (data['results'] ?? []);
      }
    } catch (e) {
      debugPrint('getDocuments error: $e');
    }
    return [];
  }

  static Future<List<dynamic>> searchKnowledge(String query) async {
    try {
      final url = Uri.parse('$baseUrl/api/documents/items/search/?q=${Uri.encodeComponent(query)}');
      final res = await http.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['results'] ?? [];
      }
    } catch (e) {
      debugPrint('searchKnowledge error: $e');
    }
    return [];
  }

  // --- Approvals ---

  static Future<List<dynamic>> getApprovals({String? status}) async {
    try {
      String path = '$baseUrl/api/approvals/requests/?';
      if (status != null) path += 'status=$status&';
      final res = await http.get(Uri.parse(path), headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data is List ? data : (data['results'] ?? []);
      }
    } catch (e) {
      debugPrint('getApprovals error: $e');
    }
    return [];
  }

  static Future<bool> decideApproval(String id, bool approve, {String note = ''}) async {
    try {
      final action = approve ? 'approve' : 'reject';
      final url = Uri.parse('$baseUrl/api/approvals/requests/$id/$action/');
      final res = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({'decision_note': note}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> createApproval({
    required String title,
    required String description,
    required String category,
  }) async {
    final url = Uri.parse('$baseUrl/api/approvals/requests/');
    final res = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
      }),
    );
    return res.statusCode == 201 ? jsonDecode(res.body) : null;
  }

  // --- Centria AI Assistant ---

  static Future<Map<String, dynamic>> askAI({
    required String prompt,
    String? conversationId,
    String contextType = 'general',
    String? contextId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/ai/ask/');
      final res = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'prompt': prompt,
          'conversation_id': conversationId,
          'context_type': contextType,
          'context_id': contextId ?? '',
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'AI query failed.'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- Platform Admin ---

  static Future<Map<String, dynamic>?> getPlatformAdminOverview() async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/platform-admin/');
      final res = await http.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('Platform admin error: $e');
    }
    return null;
  }

  static String get wsBaseUrl {
    if (_envWsBaseUrl.isNotEmpty) return _envWsBaseUrl;
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final portStr = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://${uri.host}$portStr';
  }

  // --- Realtime Configuration ---

  static Future<Map<String, dynamic>?> getRealtimeConfig() async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/realtime/config/');
      final res = await http.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('Realtime config fetch error: $e');
    }
    return null;
  }
}
