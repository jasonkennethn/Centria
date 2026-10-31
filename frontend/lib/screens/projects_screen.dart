import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/widgets/skeleton_loader.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<dynamic> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _projects = ApiService.cachedProjects ?? [];
    _isLoading = _projects.isEmpty;
    _loadProjects(showLoading: _isLoading);
  }

  Future<void> _loadProjects({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    final projects = await ApiService.getProjects();
    if (mounted) {
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    }
  }

  void _openCreateProjectDialog() {
    final nameCtrl = TextEditingController();
    final keyCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Create New Project', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Project Name', hintText: 'Customer Portal Refresh')),
            const SizedBox(height: 12),
            TextField(controller: keyCtrl, decoration: const InputDecoration(labelText: 'Project Key (2-6 letters)', hintText: 'POR')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', hintText: 'Scope and objectives')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final key = keyCtrl.text.trim().toUpperCase();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a project name.')),
                );
                return;
              }
              if (key.length < 2 || key.length > 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project key must be between 2 and 6 characters.')),
                );
                return;
              }
              await ApiService.createProject(name: name, key: key, description: descCtrl.text.trim());
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                _loadProjects();
              }
            },
            child: const Text('Create Project'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    Text('Projects', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
                    const SizedBox(height: 4),
                    Text('Manage active deliverables, client workspaces, and milestones.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openCreateProjectDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Project'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Expanded(
              child: _isLoading
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 380,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 185,
                      ),
                      itemCount: 3,
                      itemBuilder: (ctx, i) => const SkeletonLoader(width: double.infinity, height: 185, borderRadius: 16),
                    )
                  : _projects.isEmpty
                      ? Center(child: Text('No projects yet. Create your first project!', style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted)))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 380,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 185,
                          ),
                          itemCount: _projects.length,
                          itemBuilder: (context, index) {
                            final p = _projects[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: AppleGlass.decoration(radius: 22),
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(6)),
                                        child: Text(p['key'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: AppColors.pale, borderRadius: BorderRadius.circular(6)),
                                        child: Text(p['status'] as String, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.teal2)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(p['name'] as String, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                                  const SizedBox(height: 6),
                                  Text(
                                    p['description'] as String? ?? 'No description provided.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(fontSize: 12, height: 1.45, color: AppColors.muted),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${p['task_count'] ?? 0} tasks (${p['open_task_count'] ?? 0} open)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                                      const Icon(Icons.arrow_forward, size: 16, color: AppColors.teal),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
