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

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
          ? AppBar(
              title: Text('centria', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: AppColors.violet),
                  onPressed: _openAiAssistant,
                ),
              ],
            )
          : null,
      drawer: isMobile ? Drawer(child: _buildSidebar(auth, isSuper)) : null,
      body: Row(
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
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Breadcrumb / Current page label
          Text(
            _getPageTitle(),
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _openAiAssistant,
                icon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.violet),
                label: Text('Centria Assistant', style: GoogleFonts.inter(color: AppColors.violet, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
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
      color: const Color(0xFFFCFDFB),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(9)),
                child: const Center(child: Text('c', style: TextStyle(color: AppColors.lime, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 8),
              Text('centria', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: AppColors.ink)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: active ? const Color(0xFFE7F1E8) : Colors.transparent,
        leading: Icon(icon, size: 18, color: active ? AppColors.teal : const Color(0xFF708078)),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.teal2 : const Color(0xFF708078),
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
