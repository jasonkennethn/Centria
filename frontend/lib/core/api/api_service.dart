import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.statusCode = 200,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => AppConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> saveAuthTokens(String access, String refresh, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
    await prefs.setString('user_data', jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getToken();
    final headers = <String, String>{};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Generic HTTP GET
  Future<ApiResponse<dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, errorMessage: e.toString(), statusCode: 500);
    }
  }

  // Generic HTTP POST
  Future<ApiResponse<dynamic>> post(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      final res = await http
          .post(url, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 45));
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, errorMessage: e.toString(), statusCode: 500);
    }
  }

  // Generic HTTP PUT / PATCH
  Future<ApiResponse<dynamic>> patch(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      final res = await http
          .patch(url, headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, errorMessage: e.toString(), statusCode: 500);
    }
  }

  // Generic HTTP DELETE
  Future<ApiResponse<dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      final res = await http.delete(url, headers: headers).timeout(const Duration(seconds: 30));
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, errorMessage: e.toString(), statusCode: 500);
    }
  }

  ApiResponse<dynamic> _handleResponse(http.Response res) {
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      decoded = res.body;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ApiResponse(isSuccess: true, data: decoded, statusCode: res.statusCode);
    } else {
      String msg = 'Request failed (${res.statusCode})';
      if (decoded is Map && decoded.containsKey('detail')) {
        msg = decoded['detail'].toString();
      } else if (decoded is Map && decoded.containsKey('error')) {
        msg = decoded['error'].toString();
      } else if (decoded is Map) {
        msg = decoded.values.first.toString();
      }
      return ApiResponse(isSuccess: false, errorMessage: msg, data: decoded, statusCode: res.statusCode);
    }
  }

  // ================= AUTHENTICATION APIS ================= //
  Future<ApiResponse<dynamic>> register(Map<String, dynamic> data) => post('/api/auth/register/', data);
  Future<ApiResponse<dynamic>> login(String email, String password) =>
      post('/api/auth/login/', {'email': email, 'password': password});
  Future<ApiResponse<dynamic>> verifyOtp(String email, String otpCode) =>
      post('/api/auth/verify-otp/', {'email': email, 'otp_code': otpCode});
  Future<ApiResponse<dynamic>> resendOtp(String email) => post('/api/auth/resend-otp/', {'email': email});
  Future<ApiResponse<dynamic>> getProfile() => get('/api/auth/profile/');

  // ================= COMPANY & GENESIS APIS ================= //
  Future<ApiResponse<dynamic>> getWorkspaces() => get('/api/companies/workspaces/');
  Future<ApiResponse<dynamic>> runCompanyGenesis(Map<String, dynamic> data) => post('/api/companies/genesis/', data);
  Future<ApiResponse<dynamic>> getCompanies() => get('/api/companies/');
  Future<ApiResponse<dynamic>> createCompany(Map<String, dynamic> data) => post('/api/companies/', data);
  Future<ApiResponse<dynamic>> getDepartments() => get('/api/companies/departments/');
  Future<ApiResponse<dynamic>> createDepartment(Map<String, dynamic> data) => post('/api/companies/departments/', data);

  // ================= PEOPLE & HRMS APIS ================= //
  Future<ApiResponse<dynamic>> getEmployees() => get('/api/people/employees/');
  Future<ApiResponse<dynamic>> createEmployee(Map<String, dynamic> data) => post('/api/people/employees/', data);
  Future<ApiResponse<dynamic>> getLeaveRequests() => get('/api/people/leave-requests/');
  Future<ApiResponse<dynamic>> createLeaveRequest(Map<String, dynamic> data) => post('/api/people/leave-requests/', data);
  Future<ApiResponse<dynamic>> approveLeaveRequest(String id, String notes) =>
      post('/api/people/leave-requests/$id/approve/', {'review_notes': notes});
  Future<ApiResponse<dynamic>> rejectLeaveRequest(String id, String notes) =>
      post('/api/people/leave-requests/$id/reject/', {'review_notes': notes});
  Future<ApiResponse<dynamic>> getAttendance() => get('/api/people/attendance/');
  Future<ApiResponse<dynamic>> clockInOut(Map<String, dynamic> data) => post('/api/people/attendance/', data);

  // ================= WORKFLOW APIS ================= //
  Future<ApiResponse<dynamic>> getWorkflows() => get('/api/workflows/definitions/');
  Future<ApiResponse<dynamic>> createWorkflow(Map<String, dynamic> data) => post('/api/workflows/definitions/', data);
  Future<ApiResponse<dynamic>> triggerWorkflow(String id, Map<String, dynamic> payload) =>
      post('/api/workflows/definitions/$id/trigger/', payload);
  Future<ApiResponse<dynamic>> getApprovals() => get('/api/workflows/approvals/');
  Future<ApiResponse<dynamic>> executeApproval(String id, String action, String notes) =>
      post('/api/workflows/approvals/$id/$action/', {'comment': notes});

  // ================= DOCUMENT VAULT & NEON S3 ================= //
  Future<ApiResponse<dynamic>> getDocuments() => get('/api/documents/');
  Future<ApiResponse<dynamic>> uploadDocument({
    required String title,
    required String category,
    required String companyId,
    required String filename,
    required List<int> bytes,
    bool runAiAnalysis = true,
  }) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('$baseUrl/api/documents/');
      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.fields['title'] = title;
      request.fields['category'] = category;
      request.fields['company'] = companyId;
      request.fields['run_ai_analysis'] = runAiAnalysis ? 'true' : 'false';

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, errorMessage: e.toString(), statusCode: 500);
    }
  }
  Future<ApiResponse<dynamic>> triggerDocAnalysis(String docId) => post('/api/documents/$docId/analyze/', {});

  // ================= GOVERNANCE & AUDIT LOGS ================= //
  Future<ApiResponse<dynamic>> getPolicies() => get('/api/governance/policies/');
  Future<ApiResponse<dynamic>> createPolicy(Map<String, dynamic> data) => post('/api/governance/policies/', data);
  Future<ApiResponse<dynamic>> getComplianceItems() => get('/api/governance/compliance/');
  Future<ApiResponse<dynamic>> getAuditLogs() => get('/api/governance/audit-logs/');

  // ================= OPERATIONS & KANBAN ================= //
  Future<ApiResponse<dynamic>> getProjects() => get('/api/operations/projects/');
  Future<ApiResponse<dynamic>> createProject(Map<String, dynamic> data) => post('/api/operations/projects/', data);
  Future<ApiResponse<dynamic>> predictProjectRisk(String projectId) => post('/api/operations/projects/$projectId/predict_risk/', {});
  Future<ApiResponse<dynamic>> getTasks() => get('/api/operations/tasks/');
  Future<ApiResponse<dynamic>> createTask(Map<String, dynamic> data) => post('/api/operations/tasks/', data);
  Future<ApiResponse<dynamic>> updateTask(String id, Map<String, dynamic> data) => patch('/api/operations/tasks/$id/', data);

  // ================= FINANCE & INVOICES ================= //
  Future<ApiResponse<dynamic>> getFinancialSummary() => get('/api/finance/summary/');
  Future<ApiResponse<dynamic>> getInvoices() => get('/api/finance/invoices/');
  Future<ApiResponse<dynamic>> createInvoice(Map<String, dynamic> data) => post('/api/finance/invoices/', data);
  Future<ApiResponse<dynamic>> sendInvoice(String id) => post('/api/finance/invoices/$id/send_to_client/', {});
  Future<ApiResponse<dynamic>> getExpenses() => get('/api/finance/expenses/');
  Future<ApiResponse<dynamic>> createExpense(Map<String, dynamic> data) => post('/api/finance/expenses/', data);

  // ================= ANALYTICS ================= //
  Future<ApiResponse<dynamic>> getExecutiveAnalytics() => get('/api/analytics/dashboard/');

  // ================= AI ENGINE & COPILOT ================= //
  Future<ApiResponse<dynamic>> getMorningBrief(Map<String, dynamic> companyData) =>
      post('/api/ai/morning-brief/', {'company_data': companyData});
  Future<ApiResponse<dynamic>> sendCopilotMessage(String prompt, {String? context}) =>
      post('/api/ai/copilot/', {'prompt': prompt, 'context': context ?? 'Executive Cockpit'});
  Future<ApiResponse<dynamic>> omnibarSearch(String query) =>
      post('/api/ai/omnibar/', {'query': query});

  // ================= CUSTOMIZATION ================= //
  Future<ApiResponse<dynamic>> getCustomFields(String targetModel) =>
      get('/api/customization/fields/?target_model=$targetModel');
  Future<ApiResponse<dynamic>> createCustomField(Map<String, dynamic> data) =>
      post('/api/customization/fields/', data);
}
