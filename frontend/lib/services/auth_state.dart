import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/services/realtime_service.dart';

class AuthState extends ChangeNotifier {
  static final AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  bool get isAuthenticated => _user != null;

  String get userName => _user?['full_name'] ?? 'Team Member';
  String get userEmail => _user?['email'] ?? '';
  bool get isPlatformAdmin => _user?['is_platform_admin'] == true;

  String get companyName => _user?['company_details']?['name'] ?? _user?['company']?['name'] ?? 'My Workspace';
  String get companySlug => _user?['company_details']?['slug'] ?? _user?['company']?['slug'] ?? 'workspace';
  String? get companyId => _user?['company_details']?['id']?.toString() ?? _user?['company']?.toString();
  String get roleName => _user?['role_details']?['name'] ?? _user?['role']?['name'] ?? 'Member';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('user_data');
    if (cached != null) {
      try {
        _user = jsonDecode(cached);
      } catch (_) {}
    }

    final token = await ApiService.getToken();
    if (token != null) {
      ApiService.prefetchWorkspace();
      final me = await ApiService.getMe();
      if (me != null) {
        _user = me;
        await prefs.setString('user_data', jsonEncode(me));
      }
      RealtimeService.instance.connect();
    }
    _initialized = true;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.login(email, password);
    if (res['success']) {
      _user = res['data']['user'];
      ApiService.prefetchWorkspace();
      RealtimeService.instance.connect();
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>> register({
    required String companyName,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await ApiService.register(
      companyName: companyName,
      fullName: fullName,
      email: email,
      password: password,
    );
    if (res['success']) {
      _user = res['data']['user'];
      RealtimeService.instance.connect();
      notifyListeners();
    }
    return res;
  }

  Future<void> logout() async {
    RealtimeService.instance.disconnect();
    await ApiService.clearTokens();
    _user = null;
    notifyListeners();
  }
}
