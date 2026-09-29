import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';

class WorkflowsPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const WorkflowsPage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<WorkflowsPage> createState() => _WorkflowsPageState();
}

class _WorkflowsPageState extends State<WorkflowsPage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _workflows = [];
  List<dynamic> _approvals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final wfRes = await _api.getWorkflows();
    final apRes = await _api.getApprovals();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (wfRes.isSuccess && wfRes.data is List) _workflows = wfRes.data;
        if (apRes.isSuccess && apRes.data is List) _approvals = apRes.data;
      });
    }
  }

  void _showCreateWorkflowDialog() {
    final nameCtrl = TextEditingController();
    String selectedTrigger = 'LEAVE_REQUESTED';
    String selectedAction = 'REQUIRE_APPROVAL';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: const Text('Create Automated Workflow', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Workflow Name', hintText: 'Executive Leave Signoff'),
                ),
                const SizedBox(height: 16),
                const Text('Trigger Event', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedTrigger,
                  dropdownColor: AppTheme.darkCard,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'LEAVE_REQUESTED', child: Text('When Employee Requests Leave')),
                    DropdownMenuItem(value: 'INVOICE_CREATED', child: Text('When Client Invoice Exceeds \$5,000')),
                    DropdownMenuItem(value: 'DOCUMENT_UPLOADED', child: Text('When New Contract Uploaded to S3')),
                    DropdownMenuItem(value: 'TASK_COMPLETED', child: Text('When Sprint Milestone Finished')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedTrigger = val!),
                ),
                const SizedBox(height: 16),
                const Text('Automated Action', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedAction,
                  dropdownColor: AppTheme.darkCard,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'REQUIRE_APPROVAL', child: Text('Queue 1-Click Executive Approval')),
                    DropdownMenuItem(value: 'SEND_BREVO_EMAIL', child: Text('Send Transactional Notification via Brevo')),
                    DropdownMenuItem(value: 'GENERATE_AI_SUMMARY', child: Text('Run Gemini OCR & Contract Summary')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedAction = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                final res = await _api.createWorkflow({
                  'name': nameCtrl.text.trim(),
                  'trigger_event': selectedTrigger,
                  'action_type': selectedAction,
                  'is_active': true,
                });
                if (res.isSuccess) {
                  _loadData();
                }
              },
              child: const Text('Deploy Workflow'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerTest(String id) async {
    final res = await _api.triggerWorkflow(id, {'mock': 'test_payload'});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: res.isSuccess ? AppTheme.success : AppTheme.error,
          content: Text(res.isSuccess ? 'Workflow executed successfully!' : 'Execution failed.'),
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'Workflow Automation', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DualModeBanner(
                    title: 'Autonomous Trigger-Action Engine',
                    description: 'Configure automated company processes, Brevo alerts, and 1-click human-in-the-loop signoffs.',
                    aiButtonLabel: 'AI Suggest Workflows',
                    onAiAction: () => widget.onNavigate('/copilot'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ACTIVE WORKFLOW DEFINITIONS',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateWorkflowDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Create Rule'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  else if (_workflows.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.darkBorder)),
                      child: const Center(
                        child: Text('No custom workflows deployed yet. Click "Create Rule" or run 60s Genesis.', style: TextStyle(color: AppTheme.textMuted)),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _workflows.length,
                      itemBuilder: (ctx, idx) {
                        final wf = _workflows[idx];
                        final id = wf['id'].toString();
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppTheme.primary.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.bolt, color: AppTheme.accent, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(wf['name'] ?? 'Workflow', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Trigger: ${wf['trigger_event']}  →  Action: ${wf['action_type']}',
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _triggerTest(id),
                                  icon: const Icon(Icons.play_arrow, size: 14),
                                  label: const Text('Test Trigger', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.darkBorder,
                                    foregroundColor: AppTheme.textPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  if (_approvals.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const Text(
                      'ACTIVE HUMAN-IN-THE-LOOP APPROVAL LOG',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 12),
                    ..._approvals.map((a) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.rule, color: AppTheme.warning),
                            title: Text(a['title'] ?? 'Approval Request', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                            subtitle: Text(a['details'] ?? 'Pending executive verification', style: const TextStyle(color: AppTheme.textMuted)),
                            trailing: Text(a['status'] ?? 'PENDING', style: const TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
