import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/api_service.dart';
import 'package:centria/widgets/skeleton_loader.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  List<dynamic> _approvals = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadApprovals();
  }

  Future<void> _loadApprovals() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getApprovals(status: _filter == 'all' ? null : _filter);
    if (mounted) {
      setState(() {
        _approvals = list;
        _isLoading = false;
      });
    }
  }

  void _handleDecision(String id, bool approve) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(approve ? 'Approve Request' : 'Reject Request', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provide an optional decision note for the audit log:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 12),
            TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Decision Note', hintText: 'e.g. Verified and approved for Release 1.4')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final ok = await ApiService.decideApproval(id, approve, note: noteCtrl.text.trim());
              if (mounted) {
                Navigator.pop(ctx);
                if (ok) _loadApprovals();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: approve ? AppColors.teal : AppColors.error),
            child: Text(approve ? 'Confirm Approval' : 'Confirm Rejection'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Approvals', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
                    const SizedBox(height: 4),
                    Text('Release gates, scope modifications, and operational sign-offs.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Filter Tabs
            Wrap(
              spacing: 8,
              children: ['all', 'pending', 'approved', 'rejected'].map((s) {
                final active = _filter == s;
                return ChoiceChip(
                  label: Text(s.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.ink)),
                  selected: active,
                  selectedColor: AppColors.teal,
                  backgroundColor: Colors.white,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _filter = s);
                      _loadApprovals();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: _isLoading
                  ? const Center(child: SkeletonLoader(width: double.infinity, height: 250))
                  : _approvals.isEmpty
                      ? Center(child: Text('No approvals found under current filter.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted)))
                      : ListView.builder(
                          itemCount: _approvals.length,
                          itemBuilder: (context, idx) {
                            final app = _approvals[idx];
                            final isPending = app['status'] == 'pending';
                            final isApproved = app['status'] == 'approved';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isApproved ? AppColors.greenPale : (isPending ? AppColors.amberPale : AppColors.errorPale),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          (app['status'] as String).toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: isApproved ? AppColors.greenDone : (isPending ? AppColors.amber : AppColors.error),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Category: ${(app['category'] as String).toUpperCase()}',
                                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(app['title'] as String, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                                  const SizedBox(height: 6),
                                  Text(app['description'] as String, style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: const Color(0xFF5D6E63))),
                                  const SizedBox(height: 16),

                                  if (isPending)
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _handleDecision(app['id'], true),
                                          child: const Text('Approve'),
                                        ),
                                        const SizedBox(width: 10),
                                        OutlinedButton(
                                          onPressed: () => _handleDecision(app['id'], false),
                                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    )
                                  else if (app['decision_note'] != null && (app['decision_note'] as String).isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(8)),
                                      child: Text('Decision Note: ${app['decision_note']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.ink)),
                                    ),
                                ],
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
