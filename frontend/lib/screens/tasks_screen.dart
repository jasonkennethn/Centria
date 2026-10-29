import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/widgets/skeleton_loader.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<dynamic> _tasks = [];
  bool _isLoading = true;

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
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await ApiService.getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  Future<void> _moveTask(String taskId, String newStatus) async {
    final ok = await ApiService.updateTaskStatus(taskId, newStatus);
    if (ok) _loadTasks();
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
                value: priority,
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
                if (titleCtrl.text.isEmpty) return;
                final projects = await ApiService.getProjects();
                if (projects.isNotEmpty) {
                  await ApiService.createTask(projectId: projects.first['id'], title: titleCtrl.text.trim(), priority: priority);
                  if (mounted) {
                    Navigator.pop(ctx);
                    _loadTasks();
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

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tasks & Issues', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
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

            // Kanban Columns
            Expanded(
              child: _isLoading
                  ? const Center(child: SkeletonLoader(width: double.infinity, height: 300))
                  : isMobile
                      ? ListView(
                          children: _columns.map((c) => _buildKanbanColumn(c['key']!, c['label']!)).toList(),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
