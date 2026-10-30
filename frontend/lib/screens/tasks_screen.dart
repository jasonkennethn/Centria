import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/widgets/skeleton_loader.dart';

import 'dart:async';
import 'package:centria/services/realtime_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<dynamic> _tasks = [];
  bool _isLoading = true;
  StreamSubscription? _tasksSub;

  final List<Map<String, String>> _columns = [
    {'key': 'todo', 'label': 'To Do'},
    {'key': 'in_progress', 'label': 'In Progress'},
    {'key': 'in_review', 'label': 'In Review'},
    {'key': 'done', 'label': 'Done'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _tasksSub = RealtimeService.instance.tasksStream.listen((event) {
      final eventName = event['event'];
      final data = event['data'] as Map<String, dynamic>? ?? {};
      if (eventName == 'task_updated') {
        final taskId = data['id'];
        final idx = _tasks.indexWhere((t) => t['id'] == taskId);
        if (idx != -1 && mounted) {
          setState(() {
            _tasks[idx] = {..._tasks[idx], ...data};
          });
        } else {
          _loadTasks(showLoading: false);
        }
      } else if (eventName == 'task_created' || eventName == 'task_comment_created') {
        _loadTasks(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }

  Future<void> _loadTasks({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    final tasks = await ApiService.getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  Future<void> _moveTask(String taskId, String newStatus) async {
    // Optimistic UI update
    final idx = _tasks.indexWhere((t) => t['id'] == taskId);
    if (idx != -1) {
      setState(() {
        _tasks[idx] = {..._tasks[idx], 'status': newStatus};
      });
    }
    final ok = await ApiService.updateTaskStatus(taskId, newStatus);
    if (!ok && mounted) {
      _loadTasks(showLoading: false);
    }
  }

  void _openCreateTaskDialog() {
    final titleCtrl = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Create Issue / Task', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Task Title', hintText: 'Implement responsive navbar')),
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
                final title = titleCtrl.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a task title.')),
                  );
                  return;
                }
                final projects = await ApiService.getProjects();
                if (projects.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No project available. Please create a project first.')),
                    );
                  }
                  return;
                }
                await ApiService.createTask(projectId: projects.first['id'], title: title, priority: priority);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  _loadTasks();
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

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        Text('Tasks & Issues', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
                        ValueListenableBuilder<bool>(
                          valueListenable: RealtimeService.instance.isConnected,
                          builder: (ctx, connected, _) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: connected ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: connected ? const Color(0xFFA5D6A7) : const Color(0xFFFFCC80)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: connected ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  connected ? 'Live Synced' : 'Connecting...',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: connected ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Kanban execution board across active projects.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openCreateTaskDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Issue'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Kanban Columns (Responsive: horizontal scroll on screens < 1140px, full stretch on desktop)
            Expanded(
              child: _isLoading
                  ? Row(
                      children: List.generate(
                        isMobile ? 1 : 4,
                        (i) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                            child: const SkeletonLoader(width: double.infinity, height: double.infinity, borderRadius: 16),
                          ),
                        ),
                      ),
                    )
                  : width < 1140
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _columns.map((c) {
                              return Container(
                                width: 290,
                                margin: const EdgeInsets.only(right: 14),
                                child: _buildKanbanColumn(c['key']!, c['label']!),
                              );
                            }).toList(),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _columns.map((c) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: _buildKanbanColumn(c['key']!, c['label']!),
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(String statusKey, String label) {
    final colTasks = _tasks.where((t) => t['status'] == statusKey).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E7DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                child: Text('${colTasks.length}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: colTasks.length,
              itemBuilder: (context, idx) {
                final task = colTasks[idx];
                final priority = task['priority'] as String? ?? 'medium';
                final isUrgent = priority == 'urgent' || priority == 'high';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(task['key'] as String? ?? '', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.teal)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUrgent ? AppColors.amberPale : AppColors.soft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(priority.toUpperCase(), style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: isUrgent ? AppColors.amber : AppColors.ink)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(task['title'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, height: 1.35)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Lead: Priya', style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted)),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz, size: 16),
                            onSelected: (newStatus) => _moveTask(task['id'], newStatus),
                            itemBuilder: (context) => _columns
                                .where((c) => c['key'] != statusKey)
                                .map((c) => PopupMenuItem(value: c['key'], child: Text('Move to ${c['label']}')))
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
