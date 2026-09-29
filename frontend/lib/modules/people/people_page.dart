import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';

class PeoplePage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const PeoplePage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  bool _isLoading = true;
  List<dynamic> _employees = [];
  List<dynamic> _leaveRequests = [];
  List<dynamic> _attendance = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPeopleData();
  }

  Future<void> _loadPeopleData() async {
    setState(() => _isLoading = true);

    final empRes = await _api.getEmployees();
    final leaveRes = await _api.getLeaveRequests();
    final attRes = await _api.getAttendance();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (empRes.isSuccess && empRes.data is List) {
          _employees = empRes.data;
        }
        if (leaveRes.isSuccess && leaveRes.data is List) {
          _leaveRequests = leaveRes.data;
        }
        if (attRes.isSuccess && attRes.data is List) {
          _attendance = attRes.data;
        }
      });
    }
  }

  void _showAddEmployeeDialog() {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Add New Employee', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'First Name', hintText: 'Elena'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Last Name', hintText: 'Rostova'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Work Email', hintText: 'elena@company.com'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Job Title', hintText: 'VP of AI Research'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (firstNameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              final res = await _api.createEmployee({
                'first_name': firstNameCtrl.text.trim(),
                'last_name': lastNameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'job_title': titleCtrl.text.trim(),
              });
              if (res.isSuccess) {
                _loadPeopleData();
              }
            },
            child: const Text('Save Employee'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLeaveApproval(String id, bool approve) async {
    final res = approve
        ? await _api.approveLeaveRequest(id, 'Approved via HRMS')
        : await _api.rejectLeaveRequest(id, 'Rejected via HRMS');
    if (res.isSuccess) {
      _loadPeopleData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'People & HRMS', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DualModeBanner(
                    title: 'HRMS Dual-Control Suite',
                    description: 'Full manual control over directory, payroll bands, and leaves with 1-click AI onboarding task sequencing.',
                    aiButtonLabel: 'AI Draft NDA / Offer',
                    onAiAction: () => widget.onNavigate('/copilot'),
                  ),

                  // Header with Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: AppTheme.primary,
                        labelColor: AppTheme.textPrimary,
                        unselectedLabelColor: AppTheme.textMuted,
                        tabs: [
                          Tab(text: 'Directory (${_employees.length})'),
                          Tab(text: 'Leave Requests (${_leaveRequests.length})'),
                          Tab(text: 'Attendance Log (${_attendance.length})'),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddEmployeeDialog,
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('Add Employee'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.darkBorder),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  else
                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildEmployeeList(),
                          _buildLeaveRequestsList(),
                          _buildAttendanceList(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (_employees.isEmpty) {
      return const Center(child: Text('No employees found in workspace.', style: TextStyle(color: AppTheme.textMuted)));
    }
    return ListView.builder(
      itemCount: _employees.length,
      itemBuilder: (ctx, idx) {
        final emp = _employees[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withAlpha(40),
              child: Text(
                '${emp['first_name']?[0] ?? ''}${emp['last_name']?[0] ?? ''}',
                style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '${emp['first_name'] ?? ''} ${emp['last_name'] ?? ''}',
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${emp['job_title'] ?? 'Staff'} • ${emp['email'] ?? ''}', style: const TextStyle(color: AppTheme.textMuted)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: emp['employment_status'] == 'ACTIVE' ? AppTheme.success.withAlpha(20) : AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                emp['employment_status'] ?? 'ACTIVE',
                style: TextStyle(
                  color: emp['employment_status'] == 'ACTIVE' ? AppTheme.success : AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveRequestsList() {
    if (_leaveRequests.isEmpty) {
      return const Center(child: Text('No active leave requests.', style: TextStyle(color: AppTheme.textMuted)));
    }
    return ListView.builder(
      itemCount: _leaveRequests.length,
      itemBuilder: (ctx, idx) {
        final leave = _leaveRequests[idx];
        final id = leave['id'].toString();
        final status = leave['status'] ?? 'PENDING';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.event_busy, color: AppTheme.warning),
            title: Text('${leave['leave_type'] ?? 'PAID'} Leave (${leave['start_date']} to ${leave['end_date']})', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            subtitle: Text('Reason: ${leave['reason'] ?? 'Personal'}', style: const TextStyle(color: AppTheme.textMuted)),
            trailing: status == 'PENDING'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: AppTheme.success),
                        tooltip: 'Approve Leave',
                        onPressed: () => _handleLeaveApproval(id, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: AppTheme.error),
                        tooltip: 'Reject Leave',
                        onPressed: () => _handleLeaveApproval(id, false),
                      ),
                    ],
                  )
                : Text(status, style: TextStyle(color: status == 'APPROVED' ? AppTheme.success : AppTheme.error, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    if (_attendance.isEmpty) {
      return const Center(child: Text('No attendance records logged.', style: TextStyle(color: AppTheme.textMuted)));
    }
    return ListView.builder(
      itemCount: _attendance.length,
      itemBuilder: (ctx, idx) {
        final att = _attendance[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.access_time, color: AppTheme.accent),
            title: Text('Date: ${att['date'] ?? 'Today'}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            subtitle: Text('Status: ${att['status'] ?? 'PRESENT'}', style: const TextStyle(color: AppTheme.textMuted)),
          ),
        );
      },
    );
  }
}
