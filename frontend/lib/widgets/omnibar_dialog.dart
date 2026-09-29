import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/api/api_service.dart';

class OmnibarDialog extends StatefulWidget {
  const OmnibarDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(180),
      builder: (ctx) => const OmnibarDialog(),
    );
  }

  @override
  State<OmnibarDialog> createState() => _OmnibarDialogState();
}

class _OmnibarDialogState extends State<OmnibarDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final res = await _api.omnibarSearch(query.trim());
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.isSuccess) {
          _result = res.data;
        } else {
          _result = {
            'action_type': 'ERROR',
            'feedback': res.errorMessage ?? 'Search failed',
          };
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Center(
        child: Container(
          width: 650,
          constraints: const BoxConstraints(maxHeight: 550),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withAlpha(100), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(40),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppTheme.accent, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Type a command, employee name, invoice, or ask AI...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: _handleSearch,
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBorder,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ESC', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ),
                  ],
                ),
              ),

              // Results or Suggestions
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _result != null
                      ? _buildResultView()
                      : _buildDefaultShortcuts(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final type = _result!['action_type'] ?? 'SEARCH';
    final feedback = _result!['feedback'] ?? '';
    final matches = _result!['matches'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primary.withAlpha(60)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '[$type] $feedback',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Search Matches', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...matches.map((m) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.darkBorder, borderRadius: BorderRadius.circular(6)),
                  child: Icon(_getIconForType(m['type']), size: 16, color: AppTheme.accent),
                ),
                title: Text(m['title'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                subtitle: Text(m['subtitle'] ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
        ],
      ],
    );
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'employee':
        return Icons.person_outline;
      case 'invoice':
        return Icons.receipt_long_outlined;
      case 'task':
        return Icons.check_circle_outline;
      case 'document':
        return Icons.description_outlined;
      case 'policy':
        return Icons.policy_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildDefaultShortcuts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS & AI SHORTCUTS',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        _buildShortcutItem(Icons.add_task, 'Create New Task', 'Operations / Kanban', 'create task Refactor API'),
        _buildShortcutItem(Icons.person_add_outlined, 'Onboard New Employee', 'HRMS Management', 'hire Alex Wong as Staff Engineer'),
        _buildShortcutItem(Icons.receipt_outlined, 'Generate Client Invoice', 'Finance System', 'invoice Acme Corp 5000'),
        _buildShortcutItem(Icons.auto_awesome, 'Ask Executive Copilot', 'Gemini AI Engine', 'calculate Q3 revenue runway'),
        _buildShortcutItem(Icons.shield_outlined, 'Review Compliance Status', 'Governance & Audit', 'show audit logs'),
      ],
    );
  }

  Widget _buildShortcutItem(IconData icon, String title, String subtitle, String queryExample) {
    return InkWell(
      onTap: () {
        _searchController.text = queryExample;
        _handleSearch(queryExample);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.darkBorder, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.subdirectory_arrow_left, size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
