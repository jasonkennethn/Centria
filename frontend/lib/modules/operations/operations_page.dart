import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';

class OperationsPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const OperationsPage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _projects = [];
  List<dynamic> _tasks = [];
  String? _riskPrediction;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final prjRes = await _api.getProjects();
    final taskRes = await _api.getTasks();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (prjRes.isSuccess && prjRes.data is List) _projects = prjRes.data;
        if (taskRes.isSuccess && taskRes.data is List) _tasks = taskRes.data;
      });
    }
  }

  void _showCreateTaskDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'HIGH';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: const Text('Add Kanban Sprint Task', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Task Title', hintText: 'Implement Neon S3 Presigned Uploads'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                dropdownColor: AppTheme.darkCard,
                style: const TextStyle(color: AppTheme.textPrimary),
                items: const [
                  DropdownMenuItem(value: 'URGENT', child: Text('🔴 Urgent')),
                  DropdownMenuItem(value: 'HIGH', child: Text('🟠 High Priority')),
                  DropdownMenuItem(value: 'MEDIUM', child: Text('🟡 Medium Priority')),
                  DropdownMenuItem(value: 'LOW', child: Text('🟢 Low Priority')),
                ],
                onChanged: (val) => setDialogState(() => priority = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Task Specification'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                final res = await _api.createTask({
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'priority': priority,
                  'status': 'TODO',
                });
                if (res.isSuccess) _loadData();
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStatusChange(String taskId, String newStatus) async {
    final res = await _api.updateTask(taskId, {'status': newStatus});
    if (res.isSuccess) _loadData();
  }

  Future<void> _runRiskPrediction() async {
    if (_projects.isEmpty) return;
    final projectId = _projects.first['id'].toString();
    final res = await _api.predictProjectRisk(projectId);
    if (mounted && res.isSuccess) {
      setState(() {
        _riskPrediction = res.data['summary'] ?? 'Project velocity on schedule.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoTasks = _tasks.where((t) => t['status'] == 'TODO').toList();
    final inProgressTasks = _tasks.where((t) => t['status'] == 'IN_PROGRESS').toList();
    final doneTasks = _tasks.where((t) => t['status'] == 'DONE').toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'Product & Operations (Kanban)', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DualModeBanner(
                    title: 'Kanban Operations & Velocity Predictor',
                    description: 'Sprint planning and task dispatching with Gemini predictive bottleneck analysis.',
                    aiButtonLabel: 'Forecast Sprint Risk',
                    onAiAction: _runRiskPrediction,
                  ),

                  if (_riskPrediction != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.accent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology, color: AppTheme.accent, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Gemini Delay-Risk Prediction: $_riskPrediction',
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SPRINT TASK BOARD',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateTaskDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Sprint Task'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  else
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isWide = constraints.maxWidth > 900;
                        return isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildColumn('To Do', todoTasks, AppTheme.textMuted, 'IN_PROGRESS')),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildColumn('In Progress', inProgressTasks, AppTheme.warning, 'DONE')),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildColumn('Completed', doneTasks, AppTheme.success, 'TODO')),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildColumn('To Do', todoTasks, AppTheme.textMuted, 'IN_PROGRESS'),
                                  const SizedBox(height: 16),
                                  _buildColumn('In Progress', inProgressTasks, AppTheme.warning, 'DONE'),
                                  const SizedBox(height: 16),
                                  _buildColumn('Completed', doneTasks, AppTheme.success, 'TODO'),
                                ],
                              );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, List<dynamic> columnTasks, Color accentColor, String nextStatus) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                '$title (${columnTasks.length})',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppTheme.darkBorder),
          const SizedBox(height: 10),

          if (columnTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No tasks', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))),
            )
          else
            ...columnTasks.map((t) {
              final id = t['id'].toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            t['title'] ?? 'Task',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        InkWell(
                          onTap: () => _handleStatusChange(id, nextStatus),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.primary.withAlpha(40), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Move →', style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    if (t['description'] != null && t['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(t['description'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
