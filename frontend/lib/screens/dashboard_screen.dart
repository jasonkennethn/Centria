import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/auth_state.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/widgets/skeleton_loader.dart';
import 'package:centria/widgets/ai_assistant_sheet.dart';

import 'dart:async';
import 'package:centria/services/realtime_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  StreamSubscription? _dashboardSub;
  StreamSubscription? _approvalsSub;
  StreamSubscription? _tasksSub;

  @override
  void initState() {
    super.initState();
    _dashboardData = ApiService.cachedDashboard;
    _isLoading = (_dashboardData == null);
    _fetchDashboard(showLoading: _isLoading);
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _dashboardSub = RealtimeService.instance.dashboardStream.listen((event) {
      if (mounted && _dashboardData != null) {
        setState(() {
          final recent = List<Map<String, dynamic>>.from(_dashboardData!['recent_activity'] ?? []);
          recent.insert(0, Map<String, dynamic>.from(event['data'] ?? {}));
          if (recent.length > 8) recent.removeLast();
          _dashboardData!['recent_activity'] = recent;
        });
      }
    });

    _approvalsSub = RealtimeService.instance.approvalsStream.listen((event) {
      if (mounted && _dashboardData != null && event['data']?['pending_count'] != null) {
        setState(() {
          final metrics = Map<String, dynamic>.from(_dashboardData!['metrics'] ?? {});
          metrics['pending_approvals'] = event['data']['pending_count'];
          _dashboardData!['metrics'] = metrics;
        });
      }
    });

    _tasksSub = RealtimeService.instance.tasksStream.listen((_) {
      if (mounted) {
        _fetchDashboard(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _dashboardSub?.cancel();
    _approvalsSub?.cancel();
    _tasksSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchDashboard({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    final data = await ApiService.getDashboard();
    if (mounted) {
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTaskDone(String taskId, String currentStatus) async {
    final nextStatus = currentStatus == 'done' ? 'todo' : 'done';
    final ok = await ApiService.updateTaskStatus(taskId, nextStatus);
    if (ok) {
      _fetchDashboard();
    }
  }

  void _openCreateTaskDialog() {
    final titleController = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Create Quick Task', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title', hintText: 'e.g. Verify release checklist'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (val) => setDlgState(() => priority = val ?? 'medium'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final text = titleController.text.trim();
                if (text.isEmpty) return;
                // Fetch first project ID
                final projects = await ApiService.getProjects();
                if (projects.isNotEmpty) {
                  final pId = projects.first['id'];
                  await ApiService.createTask(projectId: pId, title: text, priority: priority);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (mounted) {
                    _fetchDashboard();
                  }
                }
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 860;
    final user = AuthState().user;
    final userName = user?['full_name'] ?? 'Priya Sharma';

    final metrics = _dashboardData?['metrics'] ?? {};
    final nextSteps = (_dashboardData?['next_steps'] as List?) ?? [];
    final activities = (_dashboardData?['recent_activity'] as List?) ?? [];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: RefreshIndicator(
        onRefresh: _fetchDashboard,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting & Create Button
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Text(
                            'Good morning, $userName',
                            style: GoogleFonts.inter(fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.w700, letterSpacing: -0.8),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: RealtimeService.instance.isConnected,
                            builder: (ctx, connected, _) {
                              if (!connected) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFA5D6A7)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Live Synced',
                                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2E7D32)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Here's what needs your attention today in Centria.", style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _openCreateTaskDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Task'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 4 Metrics Cards Grid (Dynamically auto-fitting across screen sizes)
              if (_isLoading)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisExtent: 110,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: 4,
                  itemBuilder: (ctx, i) => const SkeletonLoader(width: double.infinity, height: 110, borderRadius: 16),
                )
              else
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisExtent: 110,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  children: [
                    _metricCard('Active projects', '${metrics['active_projects'] ?? 0}', 'Across workspace', Icons.folder_outlined, AppColors.teal),
                    _metricCard('Open issues', '${metrics['open_issues'] ?? 0}', '${metrics['urgent_issues'] ?? 0} urgent', Icons.check_box_outlined, AppColors.amber),
                    _metricCard('Pending review', '${metrics['pending_reviews'] ?? 0}', 'Release gates active', Icons.verified_user_outlined, AppColors.teal2),
                    _metricCard('Team members', '${user?['company_details']?['plan'] ?? 'Growth'}', 'Operational tier', Icons.people_outline, AppColors.violet),
                  ],
                ),
              const SizedBox(height: 32),

              // Split Section: Next Steps & AI Grounded Assistant Card
              isMobile
                  ? Column(
                      children: [
                        _buildNextStepsCard(nextSteps),
                        const SizedBox(height: 20),
                        _buildAiCard(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 58, child: _buildNextStepsCard(nextSteps)),
                        const SizedBox(width: 24),
                        Expanded(flex: 42, child: _buildAiCard()),
                      ],
                    ),
              const SizedBox(height: 32),

              // Recent Team Activity Stream
              _buildActivityFeed(activities),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, String sub, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: AppleGlass.decoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                ],
              ),
              Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
              Text(sub, style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepsCard(List<dynamic> nextSteps) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppleGlass.decoration(radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Next Steps', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${nextSteps.length} items', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (nextSteps.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No pending tasks assigned to you. All clear!', style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                  ),
                )
              else
                Column(
                  children: nextSteps.map((task) {
                    final isDone = task['status'] == 'done';
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.04))),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _toggleTaskDone(task['id'], task['status']),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isDone ? const Color(0xFFE1F1E4) : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: isDone ? const Color(0xFF9FC9AA) : Colors.black.withValues(alpha: 0.14),
                                ),
                              ),
                              child: isDone ? const Center(child: Text('✓', style: TextStyle(color: Color(0xFF377750), fontSize: 13, fontWeight: FontWeight.bold))) : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['title'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDone ? AppColors.muted : AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text('${task['key']} · Priority: ${task['priority']}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDone ? AppColors.greenPale : AppColors.soft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task['status'] as String,
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: isDone ? AppColors.greenDone : AppColors.ink),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppleGlass.decoration(
            radius: 24,
            color: const Color(0xFFF7F4FD).withValues(alpha: 0.85),
            borderColor: const Color(0xFFE5DCF8).withValues(alpha: 0.95),
            glow: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.violet.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome, size: 16, color: AppColors.violet),
                  ),
                  const SizedBox(width: 10),
                  Text('Centria Operations AI', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.violet)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Release 1.4 is pending sign-off from the release gatekeeper. The checklist and change requests have been verified against recent documentation.",
                style: GoogleFonts.inter(fontSize: 12, height: 1.6, color: const Color(0xFF5F5875)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4DFF0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 14, color: AppColors.violet),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Evidence: Release checklist · Version 3',
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF70668F), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const AiAssistantSheet(contextType: 'reporting'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Open AI Assistant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityFeed(List<dynamic> activities) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppleGlass.decoration(radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Team Activity', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
              const SizedBox(height: 16),
              if (activities.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('No activity logs recorded yet.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
                )
              else
                Column(
                  children: activities.map((act) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(act['description'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.ink)),
                          ),
                          Text(act['user'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
