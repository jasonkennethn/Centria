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

  // Persistent HTTP client with connection pooling and keep-alive (drastically cuts latency)
  static final http.Client _client = http.Client();

  // Hardware-backed secure storage for sensitive authentication credentials
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;

  // In-memory cache for ultra-fast instant UI rendering (0 ms latency)
  static Map<String, dynamic>? _cachedDashboard;
  static List<dynamic>? _cachedProjects;
  static List<dynamic>? _cachedTasks;
  static List<dynamic>? _cachedApprovals;
  static List<dynamic>? _cachedDocuments;
  static Map<String, dynamic>? _cachedMe;

  static Map<String, dynamic>? get cachedDashboard => _cachedDashboard;
  static List<dynamic>? get cachedProjects => _cachedProjects;
  static List<dynamic>? get cachedTasks => _cachedTasks;
  static List<dynamic>? get cachedApprovals => _cachedApprovals;
  static List<dynamic>? get cachedDocuments => _cachedDocuments;
  static Map<String, dynamic>? get cachedMe => _cachedMe;

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
    _cachedDashboard = null;
    _cachedProjects = null;
    _cachedTasks = null;
    _cachedApprovals = null;
    _cachedDocuments = null;
    _cachedMe = null;
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
      final res = await _client.post(
        url,
        headers: await _headers(needsAuth: false),
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );
      final data = _parseJson(res);
      if (res.statusCode == 200 && data is Map<String, dynamic>) {
        await saveTokens(access: data['access'], refresh: data['refresh']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        // Prefetch data immediately after login
        prefetchWorkspace();
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
      final res = await _client.post(
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
        prefetchWorkspace();
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
      final res = await _client.post(
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
      final res = await _client.post(
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

  static Future<Map<String, dynamic>?> getMe({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedMe != null) {
      _fetchMeDirect();
      return _cachedMe;
    }
    return await _fetchMeDirect();
  }

  static Future<Map<String, dynamic>?> _fetchMeDirect() async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/me/');
      final res = await _client.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _cachedMe = data;
        return data;
      }
    } catch (e) {
      debugPrint('getMe error: $e');
    }
    return _cachedMe;
  }

  // --- Dashboard & Projects ---

  static Future<Map<String, dynamic>?> getDashboard({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDashboard != null) {
      _fetchDashboardDirect();
      return _cachedDashboard;
    }
    return await _fetchDashboardDirect();
  }

  static Future<Map<String, dynamic>?> _fetchDashboardDirect() async {
    try {
      final url = Uri.parse('$baseUrl/api/projects/dashboard/');
      final res = await _client.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _cachedDashboard = data;
        return data;
      }
    } catch (e) {
      debugPrint('getDashboard error: $e');
    }
    return _cachedDashboard;
  }

  static Future<List<dynamic>> getProjects({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProjects != null) {
      _fetchProjectsDirect();
      return _cachedProjects!;
    }
    return await _fetchProjectsDirect();
  }

  static Future<List<dynamic>> _fetchProjectsDirect() async {
    try {
      final url = Uri.parse('$baseUrl/api/projects/items/');
      final res = await _client.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data is List ? data : (data['results'] ?? [])) as List<dynamic>;
        _cachedProjects = list;
        return list;
      }
    } catch (e) {
      debugPrint('getProjects error: $e');
    }
    return _cachedProjects ?? [];
  }

  static Future<Map<String, dynamic>?> createProject({
    required String name,
    required String key,
    String description = '',
  }) async {
    final url = Uri.parse('$baseUrl/api/projects/items/');
    final res = await _client.post(
      url,
      headers: await _headers(),
      body: jsonEncode({'name': name, 'key': key.toUpperCase(), 'description': description}),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      _cachedDashboard = null;
      if (_cachedProjects != null) {
        _cachedProjects = [data, ..._cachedProjects!];
      }
      return data;
    }
    return null;
  }

  static Future<List<dynamic>> getTasks({String? projectId, String? status, bool forceRefresh = false}) async {
    final isUnfiltered = (projectId == null && status == null);
    if (isUnfiltered && !forceRefresh && _cachedTasks != null) {
      _fetchTasksDirect(projectId: projectId, status: status);
      return _cachedTasks!;
    }
    return await _fetchTasksDirect(projectId: projectId, status: status);
  }

  static Future<List<dynamic>> _fetchTasksDirect({String? projectId, String? status}) async {
    try {
      String path = '$baseUrl/api/projects/tasks/?';
      if (projectId != null) path += 'project=$projectId&';
      if (status != null) path += 'status=$status&';
      final res = await _client.get(Uri.parse(path), headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data is List ? data : (data['results'] ?? [])) as List<dynamic>;
        if (projectId == null && status == null) {
          _cachedTasks = list;
        }
        return list;
      }
    } catch (e) {
      debugPrint('getTasks error: $e');
    }
    return (projectId == null && status == null) ? (_cachedTasks ?? []) : [];
  }

  static Future<Map<String, dynamic>?> createTask({
    required String projectId,
    required String title,
    String description = '',
    String priority = 'medium',
    String taskType = 'task',
  }) async {
    final url = Uri.parse('$baseUrl/api/projects/tasks/');
    final res = await _client.post(
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
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      _cachedDashboard = null;
      if (_cachedTasks != null) {
        _cachedTasks = [data, ..._cachedTasks!];
      }
      return data;
    }
    return null;
  }

  static Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    // Optimistic cache update
    if (_cachedTasks != null) {
      final idx = _cachedTasks!.indexWhere((t) => t['id'] == taskId);
      if (idx != -1) {
        final updated = Map<String, dynamic>.from(_cachedTasks![idx]);
        updated['status'] = newStatus;
        _cachedTasks![idx] = updated;
      }
    }
    _cachedDashboard = null;

    try {
      final url = Uri.parse('$baseUrl/api/projects/tasks/$taskId/');
      final res = await _client.patch(
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

  static Future<List<dynamic>> getDocuments({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDocuments != null) {
      _fetchDocumentsDirect();
      return _cachedDocuments!;
    }
    return await _fetchDocumentsDirect();
  }

  static Future<List<dynamic>> _fetchDocumentsDirect() async {
    try {
      final url = Uri.parse('$baseUrl/api/documents/items/');
      final res = await _client.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data is List ? data : (data['results'] ?? [])) as List<dynamic>;
        _cachedDocuments = list;
        return list;
      }
    } catch (e) {
      debugPrint('getDocuments error: $e');
    }
    return _cachedDocuments ?? [];
  }

  static Future<List<dynamic>> searchKnowledge(String query) async {
    try {
      final url = Uri.parse('$baseUrl/api/documents/items/search/?q=${Uri.encodeComponent(query)}');
      final res = await _client.get(url, headers: await _headers());
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

  static Future<List<dynamic>> getApprovals({String? status, bool forceRefresh = false}) async {
    final isUnfiltered = (status == null || status == 'all');
    if (isUnfiltered && !forceRefresh && _cachedApprovals != null) {
      _fetchApprovalsDirect(status: status);
      return _cachedApprovals!;
    }
    return await _fetchApprovalsDirect(status: status);
  }

  static Future<List<dynamic>> _fetchApprovalsDirect({String? status}) async {
    try {
      String path = '$baseUrl/api/approvals/requests/?';
      if (status != null && status != 'all') path += 'status=$status&';
      final res = await _client.get(Uri.parse(path), headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data is List ? data : (data['results'] ?? [])) as List<dynamic>;
        if (status == null || status == 'all') {
          _cachedApprovals = list;
        }
        return list;
      }
    } catch (e) {
      debugPrint('getApprovals error: $e');
    }
    return (status == null || status == 'all') ? (_cachedApprovals ?? []) : [];
  }

  static Future<bool> decideApproval(String id, bool approve, {String note = ''}) async {
    _cachedDashboard = null;
    try {
      final action = approve ? 'approve' : 'reject';
      final url = Uri.parse('$baseUrl/api/approvals/requests/$id/$action/');
      final res = await _client.post(
        url,
        headers: await _headers(),
        body: jsonEncode({'decision_note': note}),
      );
      if (res.statusCode == 200 && _cachedApprovals != null) {
        final idx = _cachedApprovals!.indexWhere((a) => a['id'] == id);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(_cachedApprovals![idx]);
          updated['status'] = approve ? 'approved' : 'rejected';
          _cachedApprovals![idx] = updated;
        }
      }
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
    final res = await _client.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
      }),
    );
    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      _cachedDashboard = null;
      if (_cachedApprovals != null) {
        _cachedApprovals = [data, ..._cachedApprovals!];
      }
      return data;
    }
    return null;
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
      final res = await _client.post(
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
      final res = await _client.get(url, headers: await _headers());
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
      final res = await _client.get(url, headers: await _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('Realtime config fetch error: $e');
    }
    return null;
  }

  // --- Workspace Prefetching & Keep-Alive ---

  static bool _isPrefetching = false;
  static Future<void> prefetchWorkspace() async {
    if (_isPrefetching) return;
    _isPrefetching = true;
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        _isPrefetching = false;
        return;
      }
      // Concurrently prefetch core resources in parallel
      await Future.wait([
        _fetchDashboardDirect(),
        _fetchProjectsDirect(),
        _fetchTasksDirect(),
        _fetchApprovalsDirect(),
        _fetchDocumentsDirect(),
      ]).timeout(const Duration(seconds: 8), onTimeout: () => []);
    } catch (_) {} finally {
      _isPrefetching = false;
    }
  }
}
