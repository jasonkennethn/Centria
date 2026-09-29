import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  final Function(String route) onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accent],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 20),
                      ),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (!isMobile) ...[
                        TextButton(
                          onPressed: () => onNavigate('/privacy-policy'),
                          child: const Text('Privacy Policy', style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () => onNavigate('/terms-of-service'),
                          child: const Text('Terms of Service', style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                      ],
                      OutlinedButton(
                        onPressed: () => onNavigate('/login'),
                        child: const Text('Sign In'),
                      ),
                      ElevatedButton(
                        onPressed: () => onNavigate('/register'),
                        child: const Text('Launch Free'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hero Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: isMobile ? 60 : 100),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.primary.withAlpha(80)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: AppTheme.accent, size: 14),
                        SizedBox(width: 8),
                        Text(
                          'THE DUAL-MODE ENTERPRISE OPERATING SYSTEM',
                          style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Run Your Entire Company\nFrom One Intelligent Platform.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: isMobile ? 32 : 54,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: const Text(
                      'Centria bridges 100% full manual operational control with 1-click autonomous AI acceleration. From 60-second company genesis to HRMS, visual workflows, S3 document vaults, finance, and predictive analytics.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => onNavigate('/register'),
                        icon: const Icon(Icons.rocket_launch, size: 18),
                        label: const Text('Get Started in 60 Seconds', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => onNavigate('/login'),
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: const Text('Explore Interactive Demo', style: TextStyle(fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Technology Badges
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTechBadge(Icons.bolt, 'Google Gemini AI Engine'),
                      _buildTechBadge(Icons.storage, 'Neon DB PostgreSQL'),
                      _buildTechBadge(Icons.cloud, 'Neon Object Cloud S3'),
                      _buildTechBadge(Icons.email, 'Brevo Transactional Engine'),
                      _buildTechBadge(Icons.security, 'Immutable Governance Vault'),
                    ],
                  ),
                ],
              ),
            ),

            // Features Grid
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: 60),
              color: AppTheme.darkCard.withAlpha(80),
              child: Column(
                children: [
                  const Text(
                    '10 Core Unified Modules',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Replace 12 fragmented SaaS subscriptions with one cohesive operating ecosystem.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  GridView.count(
                    crossAxisCount: isMobile ? 1 : (screenWidth < 1200 ? 2 : 3),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        Icons.auto_awesome,
                        '60-Second Genesis Wizard',
                        'Launch a complete corporate structure with automated departments, roles, policy baselines, and charts of accounts.',
                        AppTheme.accent,
                      ),
                      _buildFeatureCard(
                        Icons.people_outline,
                        'People Management & HRMS',
                        'Employee directory, compensation bands, attendance tracking, and multi-tier leave approval chains.',
                        AppTheme.primary,
                      ),
                      _buildFeatureCard(
                        Icons.account_tree_outlined,
                        'Visual Workflow Engine',
                        'Node-based trigger-condition-action automation with human-in-the-loop 1-click executive approvals.',
                        AppTheme.success,
                      ),
                      _buildFeatureCard(
                        Icons.cloud_upload_outlined,
                        'Neon S3 Document Vault',
                        'Secure cloud storage with Gemini multimodal OCR and instant contract extraction.',
                        AppTheme.accent,
                      ),
                      _buildFeatureCard(
                        Icons.shield_outlined,
                        'Governance & Audit Trails',
                        'Corporate policy registry, regulatory compliance calendars, and immutable audit logs.',
                        AppTheme.warning,
                      ),
                      _buildFeatureCard(
                        Icons.view_kanban_outlined,
                        'Product & Operations Kanban',
                        'Sprint planning, milestone tracking, and task velocity forecasting.',
                        AppTheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 32),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.darkBorder)),
              ),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text(
                            AppConstants.appTagline,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          InkWell(
                            onTap: () => onNavigate('/privacy-policy'),
                            child: const Text('Privacy Policy', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ),
                          InkWell(
                            onTap: () => onNavigate('/terms-of-service'),
                            child: const Text('Terms of Service', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ),
                          InkWell(
                            onTap: () async {
                              final uri = Uri.parse('mailto:${AppConstants.contactEmail}');
                              if (await canLaunchUrl(uri)) launchUrl(uri);
                            },
                            child: const Text('Support', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.darkBorder),
                  const SizedBox(height: 16),
                  const Text(
                    '© 2026 Centria Technologies Inc. All rights reserved. Powered by Celarox Cloud.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accent),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
