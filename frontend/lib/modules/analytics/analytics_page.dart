import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dual_mode_banner.dart';
import '../../widgets/metric_card.dart';

class AnalyticsPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(String route) onNavigate;

  const AnalyticsPage({super.key, required this.onOpenDrawer, required this.onNavigate});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _analyticsData;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final res = await _api.getExecutiveAnalytics();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.isSuccess) _analyticsData = res.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workloads = _analyticsData?['workloads'] as List? ?? [
      {'department': 'Engineering', 'utilization': 88, 'risk': 'MODERATE'},
      {'department': 'Product & AI', 'utilization': 74, 'risk': 'LOW'},
      {'department': 'Growth & Sales', 'utilization': 92, 'risk': 'HIGH'},
      {'department': 'Operations & Legal', 'utilization': 65, 'risk': 'LOW'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          AppHeader(title: 'Predictive Analytics & Intelligence', onOpenDrawer: widget.onOpenDrawer),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  DualModeBanner(
                    title: 'Predictive Intelligence Engine',
                    description: 'Forecast operational bottlenecks, team burnout risk, and financial runway using Gemini neural models.',
                    aiButtonLabel: 'Deep Strategic Forecast',
                    onAiAction: () => widget.onNavigate('/copilot'),
                  ),

                  // Top Stats
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Average Velocity',
                          value: '94.2%',
                          subtitle: 'Sprint Milestones on Track',
                          icon: Icons.speed,
                          iconColor: AppTheme.success,
                          trend: '+3.8%',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MetricCard(
                          title: 'Predictive Risk Index',
                          value: 'Low (12%)',
                          subtitle: 'Zero Critical Blockers',
                          icon: Icons.shield_outlined,
                          iconColor: AppTheme.accent,
                          trend: 'Optimal',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MetricCard(
                          title: 'Burn Efficiency',
                          value: '1.4x',
                          subtitle: 'Output vs Capital Spent',
                          icon: Icons.trending_up,
                          iconColor: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Department Workload & Bottleneck Forecast
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bar_chart, color: AppTheme.accent, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Department Capacity & Workload Allocation',
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Monitors task density and flags overutilization before project delivery dates slip.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: AppTheme.darkBorder),
                        const SizedBox(height: 16),

                        ...workloads.map((w) {
                          final dept = w['department'] ?? 'Department';
                          final util = (w['utilization'] as num?)?.toInt() ?? 75;
                          final risk = w['risk'] ?? 'LOW';
                          final Color barColor = util > 85 ? AppTheme.error : (util > 70 ? AppTheme.warning : AppTheme.success);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(dept, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Text('$util% Allocated', style: TextStyle(color: barColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: barColor.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                                          child: Text(risk, style: TextStyle(color: barColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: util / 100.0,
                                    backgroundColor: AppTheme.darkSubtle,
                                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
