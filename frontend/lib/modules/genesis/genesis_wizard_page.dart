import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';

class GenesisWizardPage extends StatefulWidget {
  final Function(String route) onNavigate;

  const GenesisWizardPage({super.key, required this.onNavigate});

  @override
  State<GenesisWizardPage> createState() => _GenesisWizardPageState();
}

class _GenesisWizardPageState extends State<GenesisWizardPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController(text: 'Acme Robotics AI');
  final _descriptionController = TextEditingController(
    text: 'Building autonomous logistics robotics and warehouse orchestration software.',
  );
  String _selectedIndustry = 'AI / SaaS';
  String _selectedTeamSize = '5-15';
  final ApiService _api = ApiService();

  bool _isGenerating = false;
  int _currentProgressStep = 0;
  Map<String, dynamic>? _genesisResult;
  String? _errorMessage;

  final List<String> _industries = [
    'AI / SaaS',
    'FinTech & Banking',
    'E-Commerce & Retail',
    'Healthcare & BioTech',
    'Robotics & DeepTech',
    'Agency & Consulting',
  ];

  final List<String> _teamSizes = ['1-5', '5-15', '15-50', '50-200', '200+'];

  Future<void> _handleRunGenesis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _currentProgressStep = 1;
      _errorMessage = null;
      _genesisResult = null;
    });

    // Simulate animated step progression
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _currentProgressStep = 2);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _currentProgressStep = 3);
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _currentProgressStep = 4);
    });

    final res = await _api.runCompanyGenesis({
      'company_name': _companyNameController.text.trim(),
      'industry': _selectedIndustry,
      'team_size': _selectedTeamSize,
      'description': _descriptionController.text.trim(),
    });

    if (mounted) {
      setState(() {
        _isGenerating = false;
        if (res.isSuccess) {
          _genesisResult = res.data;
        } else {
          _errorMessage = res.errorMessage ?? 'Genesis failed. Please retry.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkCard,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.accent, size: 20),
            SizedBox(width: 8),
            Text('60-Second Company Genesis Wizard', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => widget.onNavigate('/dashboard'),
            icon: const Icon(Icons.dashboard_outlined, size: 16, color: AppTheme.textMuted),
            label: const Text('Skip to Cockpit', style: TextStyle(color: AppTheme.textMuted)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: _genesisResult != null ? _buildSuccessView() : _buildWizardForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildWizardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autonomous Corporate Provisioning',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Answer 3 prompts to auto-generate departments, roles, compliance policies, and chart of accounts.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppTheme.darkBorder),
          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error.withAlpha(80)),
              ),
              child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],

          // Company Name
          const Text('Company Legal Name', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _companyNameController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'e.g. Acme Technologies Inc.'),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Company name is required' : null,
          ),
          const SizedBox(height: 18),

          // Industry & Team Size Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Industry Vertical', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedIndustry,
                      dropdownColor: AppTheme.darkCard,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(),
                      items: _industries
                          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedIndustry = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Team Size', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTeamSize,
                      dropdownColor: AppTheme.darkCard,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(),
                      items: _teamSizes
                          .map((s) => DropdownMenuItem(value: s, child: Text('$s People')))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedTeamSize = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Vision / Description
          const Text('Company Core Vision & Product Description', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Describe your core product, primary customer base, and operational milestones...',
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please provide a brief description' : null,
          ),
          const SizedBox(height: 28),

          if (_isGenerating) ...[
            _buildGeneratingProgress(),
            const SizedBox(height: 24),
          ],

          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _handleRunGenesis,
            icon: const Icon(Icons.bolt, size: 20),
            label: Text(
              _isGenerating ? 'Synthesizing with Gemini AI...' : 'Generate Complete Company Architecture',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
              ),
              const SizedBox(width: 12),
              const Text('Autonomous Provisioning in Progress...', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          _buildStepRow('Structuring Executive, Engineering & Growth Departments', _currentProgressStep >= 1),
          _buildStepRow('Synthesizing Corporate Roles & Access Permissions', _currentProgressStep >= 2),
          _buildStepRow('Establishing Compliance Policies & Chart of Accounts', _currentProgressStep >= 3),
          _buildStepRow('Configuring Visual Onboarding Workflows & Approval Queues', _currentProgressStep >= 4),
        ],
      ),
    );
  }

  Widget _buildStepRow(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AppTheme.success : AppTheme.textMuted,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isDone ? AppTheme.textPrimary : AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final summary = _genesisResult!['genesis_summary'] ?? {};
    final depts = summary['departments'] as List? ?? [];
    final policies = summary['policies'] as List? ?? [];
    final accounts = summary['chart_of_accounts'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.success.withAlpha(30), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppTheme.success, size: 48),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Company Genesis Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your corporate organization has been fully structured and seeded on Neon DB.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 24),
        const Divider(color: AppTheme.darkBorder),
        const SizedBox(height: 16),

        // Generated Department Chips
        const Text('Provisioned Departments:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: depts.map((d) {
            final name = d is Map ? (d['name'] ?? '') : d.toString();
            return Chip(
              backgroundColor: AppTheme.primary.withAlpha(30),
              side: const BorderSide(color: AppTheme.primary),
              label: Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Generated Policies
        const Text('Configured Governance Policies:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: policies.map((p) {
            final title = p is Map ? (p['title'] ?? '') : p.toString();
            return Chip(
              backgroundColor: AppTheme.warning.withAlpha(20),
              side: const BorderSide(color: AppTheme.warning),
              label: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Generated Chart of Accounts
        if (accounts.isNotEmpty) ...[
          const Text('Chart of Accounts Ledger:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accounts.map((a) {
              final name = a is Map ? (a['name'] ?? '') : a.toString();
              return Chip(
                backgroundColor: AppTheme.success.withAlpha(20),
                side: const BorderSide(color: AppTheme.success),
                label: Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 28),

        ElevatedButton.icon(
          onPressed: () => widget.onNavigate('/dashboard'),
          icon: const Icon(Icons.dashboard, size: 18),
          label: const Text('Enter Executive Cockpit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
        ),
      ],
    );
  }
}
