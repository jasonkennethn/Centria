import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/auth_state.dart';
import 'package:centria/screens/dashboard_screen.dart';
import 'package:centria/screens/projects_screen.dart';
import 'package:centria/screens/tasks_screen.dart';
import 'package:centria/screens/knowledge_screen.dart';
import 'package:centria/screens/approvals_screen.dart';
import 'package:centria/screens/platform_admin_screen.dart';
import 'package:centria/widgets/ai_assistant_sheet.dart';

import 'dart:async';
import 'dart:ui';
import 'package:centria/services/api_service.dart';
import 'package:centria/services/realtime_service.dart';
import 'package:centria/widgets/app_download_dialog.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;
  StreamSubscription? _notifSub;
  int _unreadNotifs = 1;
  final List<Map<String, dynamic>> _liveNotifications = [
    {
      'title': 'Neon DB Realtime Connected',
      'message': 'Live synchronization active for tasks, approvals, and Gemini token streaming.',
      'time': 'Just now',
      'type': 'system',
    }
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    ApiService.prefetchWorkspace();
    RealtimeService.instance.connect();
    _subscribeNotifications();
  }

  void _subscribeNotifications() {
    _notifSub = RealtimeService.instance.notificationsStream.listen((event) {
      if (mounted) {
        final data = event['data'] as Map<String, dynamic>? ?? {};
        final title = data['title'] ?? 'Workspace Notification';
        final msg = data['message'] ?? '';
        setState(() {
          _unreadNotifs++;
          _liveNotifications.insert(0, {
            'title': title,
            'message': msg,
            'time': 'Just now',
            'type': data['resource_type'] ?? 'alert',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.ink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: AppColors.lime, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
                      if (msg.isNotEmpty)
                        Text(msg, style: GoogleFonts.inter(color: AppColors.muted, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  void _openNotificationsSheet() {
    setState(() => _unreadNotifs = 0);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, color: AppColors.ink, size: 22),
                      const SizedBox(width: 10),
                      Text('Live Notifications', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    ],
                  ),
                  if (_liveNotifications.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() => _liveNotifications.clear());
                        setSheetState(() {});
                      },
                      child: Text('Clear All', style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const Divider(height: 24, color: AppColors.line),
              if (_liveNotifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.notifications_none, size: 40, color: AppColors.muted),
                        const SizedBox(height: 12),
                        Text('No new notifications', style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted)),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _liveNotifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.line),
                    itemBuilder: (ctx, i) {
                      final n = _liveNotifications[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: n['type'] == 'task' ? const Color(0xFFE8F5E9) : const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            n['type'] == 'task' ? Icons.task_alt : Icons.bolt,
                            color: n['type'] == 'task' ? AppColors.teal : AppColors.violet,
                            size: 20,
                          ),
                        ),
                        title: Text(n['title'] ?? '', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        subtitle: Text(n['message'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
                        trailing: Text(n['time'] ?? '', style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted)),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  void _openAiAssistant() {
    String ctx = 'general';
    if (_currentIndex == 0) ctx = 'reporting';
    if (_currentIndex == 1) ctx = 'project';
    if (_currentIndex == 2) ctx = 'task';
    if (_currentIndex == 3) ctx = 'document';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx2) => AiAssistantSheet(contextType: ctx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 860;
    final auth = AuthState();
    final isSuper = auth.isPlatformAdmin;

    final screens = [
      const DashboardScreen(),
      const ProjectsScreen(),
      const TasksScreen(),
      const KnowledgeScreen(),
      const ApprovalsScreen(),
      if (isSuper) const PlatformAdminScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: isMobile
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: AppBar(
                    backgroundColor: Colors.white.withValues(alpha: 0.82),
                    elevation: 0,
                    centerTitle: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(8)),
                              child: const Center(child: Text('c', style: TextStyle(color: AppColors.lime, fontSize: 18, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                        Text('Centria', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Badge(
                          isLabelVisible: _unreadNotifs > 0,
                          label: Text('$_unreadNotifs', style: const TextStyle(fontSize: 10)),
                          child: const Icon(Icons.notifications_outlined),
                        ),
                        onPressed: _openNotificationsSheet,
                      ),
                      IconButton(
                        icon: const Icon(Icons.auto_awesome, color: AppColors.violet),
                        onPressed: _openAiAssistant,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      drawer: isMobile ? Drawer(child: _buildSidebar(auth, isSuper)) : null,
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile)
                SizedBox(
                  width: 240,
                  child: _buildSidebar(auth, isSuper),
                ),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile) _buildTopBar(auth),
                    Expanded(child: screens[_currentIndex.clamp(0, screens.length - 1)]),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppDownloadHoverDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAiAssistant,
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text('Ask AI', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  Widget _buildTopBar(AuthState auth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Breadcrumb / Current page label
              Flexible(
                child: Text(
                  _getPageTitle(),
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: RealtimeService.instance.isConnected,
                    builder: (ctx, connected, _) {
                      if (!connected) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
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
                            if (!compact) ...[
                              const SizedBox(width: 6),
                              Text(
                                'Neon DB Live',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  compact
                      ? IconButton(
                          onPressed: _openAiAssistant,
                          icon: const Icon(Icons.auto_awesome, size: 18, color: AppColors.violet),
                          tooltip: 'Centria Assistant',
                        )
                      : OutlinedButton.icon(
                          onPressed: _openAiAssistant,
                          icon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.violet),
                          label: Text('Centria Assistant', style: GoogleFonts.inter(color: AppColors.violet, fontWeight: FontWeight.w700)),
                        ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Badge(
                      isLabelVisible: _unreadNotifs > 0,
                      label: Text('$_unreadNotifs', style: const TextStyle(fontSize: 10)),
                      child: const Icon(Icons.notifications_none_outlined, color: AppColors.ink, size: 22),
                    ),
                    tooltip: 'Notifications',
                    onPressed: _openNotificationsSheet,
                  ),
                  const SizedBox(width: 10),
                  // User Avatar
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: const Color(0xFFDFEAD5), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: const Color(0xFF45643D)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
);
}

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Workspace Overview';
      case 1:
        return 'Active Projects';
      case 2:
        return 'Task Execution & Kanban';
      case 3:
        return 'Knowledge Base & Citations';
      case 4:
        return 'Operational Approvals';
      case 5:
        return 'Platform Administration';
      default:
        return 'Centria Platform';
    }
  }

  Widget _buildSidebar(AuthState auth, bool isSuper) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        border: Border(
          right: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('c', style: TextStyle(color: AppColors.lime, fontSize: 22, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              Text('Centria', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 20),

          // Workspace Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF0F3EE), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(color: const Color(0xFFDFEAD5), borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Text(auth.companyName.isNotEmpty ? auth.companyName[0] : 'N', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF45643D)))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.companyName, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                      Text(auth.roleName, style: GoogleFonts.inter(fontSize: 9, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Navigation Links
          Text('WORKSPACE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 8),

          _navItem(0, 'My Day', Icons.calendar_today_outlined),
          _navItem(1, 'Projects', Icons.folder_outlined),
          _navItem(2, 'Issues & Tasks', Icons.check_box_outlined),
          _navItem(3, 'Knowledge', Icons.menu_book_outlined),
          _navItem(4, 'Approvals', Icons.verified_user_outlined),

          if (isSuper) ...[
            const SizedBox(height: 18),
            Text('PLATFORM', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.teal, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            _navItem(5, 'Platform Admin', Icons.admin_panel_settings_outlined),
          ],

          const Spacer(),

          // User Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.userName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                      Text(auth.userEmail, style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 18, color: AppColors.muted),
                  onPressed: () async {
                    await auth.logout();
                    if (mounted) Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, String label, IconData icon) {
    final active = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: active ? AppColors.teal.withValues(alpha: 0.12) : Colors.transparent,
        leading: Icon(icon, size: 19, color: active ? AppColors.teal : const Color(0xFF708078)),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.teal2 : const Color(0xFF708078),
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        onTap: () {
          setState(() => _currentIndex = index);
          if (MediaQuery.of(context).size.width < 860) {
            Navigator.pop(context); // close drawer
          }
        },
      ),
    );
  }
}
