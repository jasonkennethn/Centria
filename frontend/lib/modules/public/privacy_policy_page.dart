import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final Function(String route) onNavigate;

  const PrivacyPolicyPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkCard,
        elevation: 0,
        title: const Text('Privacy Policy', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
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
                  'Centria Enterprise Privacy Policy',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text('Effective Date: September 29, 2026', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 24),
                const Divider(color: AppTheme.darkBorder),
                const SizedBox(height: 20),
                _buildSection(
                  '1. Introduction & Scope',
                  'Centria Technologies Inc. ("Centria", "we", "our", or "us") provides an AI-enabled enterprise company operating system. This Privacy Policy describes how we collect, use, process, and protect company workspace data, employee records, financial records, and documents uploaded to our services.',
                ),
                _buildSection(
                  '2. Information We Collect',
                  '• Account & Organization Data: Names, corporate email addresses, business entities, roles, and authorization keys.\n• Operational & HR Data: Employee directories, job titles, department assignments, attendance logs, and leave records.\n• Financial & Document Data: Invoice totals, expense receipts, vendor records, and documents stored securely within Neon Object Cloud (S3).\n• AI Processing Metadata: Natural language queries processed via Google Gemini API for operational summaries and OCR analysis.',
                ),
                _buildSection(
                  '3. Storage, Encryption & Security',
                  'All database transactions are executed against Neon DB PostgreSQL with mandatory SSL/TLS channel binding. Stored documents and media assets reside in private Neon Object Cloud S3 buckets encrypted at rest (AES-256). All transactional emails, OTP verification codes, and security alerts are securely dispatched through Brevo API.',
                ),
                _buildSection(
                  '4. AI Processing & Third-Party LLMs',
                  'When utilizing autonomous AI features (such as 60-Second Genesis, Executive Morning Briefings, or Multimodal Document Extraction), data is transmitted securely to Google Gemini APIs. Your private corporate data is never used to train public foundational models.',
                ),
                _buildSection(
                  '5. User Rights & Data Portability',
                  'Under GDPR and CCPA regulations, enterprise administrators have full authority to request data exports, audit logs, or permanent deletion of corporate workspaces and employee records by contacting support.',
                ),
                _buildSection(
                  '6. Contact Information',
                  'If you have inquiries regarding this Privacy Policy, please contact our Data Governance Officer at ${AppConstants.contactEmail}.',
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
