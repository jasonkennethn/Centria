import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class TermsOfServicePage extends StatelessWidget {
  final Function(String route) onNavigate;

  const TermsOfServicePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkCard,
        elevation: 0,
        title: const Text('Terms of Service', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => onNavigate('/'),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Centria Enterprise Terms of Service',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text('Last Updated: September 29, 2026', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 24),
                const Divider(color: AppTheme.darkBorder),
                const SizedBox(height: 20),
                _buildSection(
                  '1. Acceptance of Terms',
                  'By accessing or using the Centria platform (via Web, Android APK, iOS IPA, or Desktop), you agree to be bound by these Terms of Service. If you are entering into this agreement on behalf of a company, organization, or other legal entity, you represent that you have the authority to bind such entity.',
                ),
                _buildSection(
                  '2. Enterprise Subscription & Dual-Mode Operations',
                  'Centria provides dual-mode company operating software comprising manual CRUD administration alongside automated AI acceleration tools. You are responsible for maintaining the confidentiality of master administrator credentials and ensuring appropriate employee permission assignments.',
                ),
                _buildSection(
                  '3. Data Ownership & Storage',
                  'You retain all rights, title, and interest in and to your company data, documents, employee records, and financial entries uploaded to Centria. Documents stored within Neon Object Cloud remain your exclusive proprietary property.',
                ),
                _buildSection(
                  '4. Service Availability & SLA',
                  'Centria strives for a 99.9% uptime service level agreement. Infrastructure maintenance and database backups are executed across Neon DB high-availability multi-region clusters.',
                ),
                _buildSection(
                  '5. Permitted Use & Security Regulations',
                  'Users agree not to attempt unauthorized penetration testing against production clusters, reverse-engineer proprietary AI models, or transmit malicious code through file vault uploads.',
                ),
                _buildSection(
                  '6. Governing Law & Dispute Resolution',
                  'These Terms shall be governed by and construed in accordance with standard international corporate jurisdiction. For questions regarding legal compliance, reach out to ${AppConstants.contactEmail}.',
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => onNavigate('/'),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String heading, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
