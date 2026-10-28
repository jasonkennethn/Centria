import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/design_tokens.dart';
import '../core/theme/typography.dart';
import '../core/components/buttons.dart';
import '../core/components/cards.dart';
import '../core/components/badges.dart';
import '../core/utils/feedback.dart';

/// 1. Splash Screen
class CentriaSplashScreen extends StatelessWidget {
  const CentriaSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentriaColors.canvasBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: CentriaColors.primary900,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(12, 74, 69, 0.2),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const StatusBadge.verified(
                    label: 'ENCLAVE ACTIVE · FIPS 140-3 LEVEL 4',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CENTRIA',
                    style: CentriaTypography.display.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                      color: CentriaColors.primary900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sovereign Company Operating System',
                    style: CentriaTypography.headlineSm.copyWith(
                      color: CentriaColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cryptographically verified executive governance, autonomous multi-currency balance sheets, and real-time statutory compliance.',
                    style: CentriaTypography.bodyMd.copyWith(
                      color: CentriaColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: CentriaButton(
                      label: 'Authenticate Executive Enclave',
                      icon: Icons.fingerprint_rounded,
                      onPressed: () => context.go('/sign-in'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CentriaButton.secondary(
                      label: 'Provision New Corporate Tenant / Signup',
                      icon: Icons.business_rounded,
                      onPressed: () => context.go('/onboarding'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Acme Global Ltd (UK #0912481) · Sovereign Enclave v3.2',
                    style: CentriaTypography.labelSm.copyWith(
                      color: CentriaColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 2. Executive Sign-In Screen
class ExecutiveSignInScreen extends StatefulWidget {
  const ExecutiveSignInScreen({super.key});

  @override
  State<ExecutiveSignInScreen> createState() => _ExecutiveSignInScreenState();
}

class _ExecutiveSignInScreenState extends State<ExecutiveSignInScreen> {
  final _emailController = TextEditingController(text: 'sarah.jenkins@acmeglobal.co.uk');
  final _pinController = TextEditingController(text: '••••••••');
  bool _obscurePin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentriaColors.canvasBase,
      appBar: AppBar(
        title: Text('Executive Sign-In', style: CentriaTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/splash'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: CentriaCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const StatusBadge.verified(label: 'UK #0912481'),
                      const Spacer(),
                      Text(
                        'Enclave TouchID',
                        style: CentriaTypography.labelSm.copyWith(
                          color: CentriaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Executive Sign-In',
                    style: CentriaTypography.headlineLg,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Authenticate your sovereign statutory credentials.',
                    style: CentriaTypography.bodySm,
                  ),
                  const SizedBox(height: 24),
                  Text('DIRECTOR EMAIL / CREDENTIAL ID', style: CentriaTypography.labelSm),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('ENCLAVE HARDWARE PIN / MASTER PASSKEY', style: CentriaTypography.labelSm),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pinController,
                    obscureText: _obscurePin,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CentriaButton(
                      label: 'Sign In with Face ID / Enclave TouchID',
                      icon: Icons.fingerprint_rounded,
                      onPressed: () {
                        CentriaFeedback.showAction(
                          context,
                          title: 'Executive Biometric Verified',
                          message: 'Access granted to Acme Global Ltd Sovereign Ledger.',
                        );
                        context.go('/overview');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CentriaButton.secondary(
                      label: 'Hardware Security Key (FIDO2 / YubiKey)',
                      icon: Icons.token_outlined,
                      onPressed: () => context.go('/hardware-key-verify'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/onboarding'),
                      child: Text(
                        'Start Enterprise Onboarding →',
                        style: CentriaTypography.labelMd.copyWith(
                          color: CentriaColors.primary700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3. Hardware Key Verification Screen
class HardwareKeyVerificationScreen extends StatelessWidget {
  const HardwareKeyVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentriaColors.canvasBase,
      appBar: AppBar(
        title: Text('Hardware Key Verification', style: CentriaTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/sign-in'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: CentriaCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: CentriaColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.usb_rounded,
                      size: 36,
                      color: CentriaColors.primary900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Touch Security Key Now',
                    style: CentriaTypography.headlineMd,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Insert your FIDO2 / WebAuthn hardware token (e.g. YubiKey 5Ci, Nitrokey 3, or Apple Secure Enclave) and touch the sensor button to sign the authentication challenge.',
                    style: CentriaTypography.bodySm,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: CentriaButton(
                      label: 'Simulate Touch Key Signature',
                      icon: Icons.fingerprint_rounded,
                      onPressed: () {
                        CentriaFeedback.showAction(
                          context,
                          title: 'FIDO2 Security Key Authenticated',
                          message: 'Sovereign Enclave session unlocked.',
                        );
                        context.go('/overview');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CentriaButton.secondary(
                      label: 'Show TOTP Backup Authenticator',
                      icon: Icons.lock_clock_outlined,
                      onPressed: () => CentriaFeedback.showAction(
                        context,
                        title: 'TOTP Input Toggled',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => CentriaFeedback.showAction(
                      context,
                      title: 'Emergency Duo Push dispatched to authorized device',
                    ),
                    child: Text(
                      'Request Emergency Duo Push to Authorized Device',
                      style: CentriaTypography.labelSm.copyWith(
                        color: CentriaColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 4. Enterprise Onboarding Screen
class EnterpriseOnboardingScreen extends StatefulWidget {
  const EnterpriseOnboardingScreen({super.key});

  @override
  State<EnterpriseOnboardingScreen> createState() => _EnterpriseOnboardingScreenState();
}

class _EnterpriseOnboardingScreenState extends State<EnterpriseOnboardingScreen> {
  int _currentStep = 0;
  String _selectedRole = 'CEO / Director';
  final _companyController = TextEditingController(text: 'Acme Global Ltd');
  final _regNumberController = TextEditingController(text: '0912481');
  final _jurisdictionController = TextEditingController(text: 'United Kingdom (Companies House)');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentriaColors.canvasBase,
      appBar: AppBar(
        title: Text('Executive Onboarding', style: CentriaTypography.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/splash'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: CentriaCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _buildStepPill(0, '1. Entity'),
                      const SizedBox(width: 8),
                      _buildStepPill(1, '2. Governance Role'),
                      const SizedBox(width: 8),
                      _buildStepPill(2, '3. Provision Ledger'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_currentStep == 0) _buildStep1(),
                  if (_currentStep == 1) _buildStep2(),
                  if (_currentStep == 2) _buildStep3(),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        CentriaButton.secondary(
                          label: 'Back',
                          onPressed: () => setState(() => _currentStep--),
                        )
                      else
                        const SizedBox.shrink(),
                      CentriaButton(
                        label: _currentStep == 2 ? 'Complete Provisioning' : 'Continue',
                        icon: _currentStep == 2 ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (_currentStep < 2) {
                            setState(() => _currentStep++);
                          } else {
                            CentriaFeedback.showAction(
                              context,
                              title: 'Sovereign Ledger Provisioned',
                              message: 'Workspace Acme Global Ltd is ready.',
                            );
                            context.go('/overview');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepPill(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? CentriaColors.primary900
              : isDone
                  ? CentriaColors.verifiedBg
                  : CentriaColors.surfaceInset,
          borderRadius: CentriaRadii.componentRadius,
          border: Border.all(
            color: isActive
                ? CentriaColors.primary900
                : isDone
                    ? CentriaColors.verifiedBorder
                    : CentriaColors.structuralStroke,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: CentriaTypography.labelSm.copyWith(
            color: isActive
                ? Colors.white
                : isDone
                    ? CentriaColors.verifiedFg
                    : CentriaColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Statutory Entity Details', style: CentriaTypography.headlineMd),
        const SizedBox(height: 4),
        Text('Identify your corporate registration for statutory filings.', style: CentriaTypography.bodySm),
        const SizedBox(height: 20),
        Text('REGISTERED LEGAL ENTITY NAME', style: CentriaTypography.labelSm),
        const SizedBox(height: 6),
        TextField(controller: _companyController),
        const SizedBox(height: 16),
        Text('COMPANIES HOUSE / REGISTRY NUMBER', style: CentriaTypography.labelSm),
        const SizedBox(height: 6),
        TextField(controller: _regNumberController),
        const SizedBox(height: 16),
        Text('PRIMARY STATUTORY JURISDICTION', style: CentriaTypography.labelSm),
        const SizedBox(height: 6),
        TextField(controller: _jurisdictionController),
      ],
    );
  }

  Widget _buildStep2() {
    final roles = ['CEO / Director', 'CFO / Treasury', 'Company Secretary', 'General Counsel'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Executive Role Selection', style: CentriaTypography.headlineMd),
        const SizedBox(height: 4),
        Text('Configures your biometric sign-off privileges and audit responsibilities.', style: CentriaTypography.bodySm),
        const SizedBox(height: 20),
        ...roles.map((r) {
          final isSelected = _selectedRole == r;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedRole = r),
              borderRadius: CentriaRadii.componentRadius,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? CentriaColors.primary50 : CentriaColors.surfaceCard,
                  borderRadius: CentriaRadii.componentRadius,
                  border: Border.all(
                    color: isSelected ? CentriaColors.primary900 : CentriaColors.structuralStroke,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? CentriaColors.primary900 : CentriaColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        r,
                        style: CentriaTypography.labelMd.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: CentriaColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check, size: 16, color: CentriaColors.primary900),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Provision Sovereign Ledger', style: CentriaTypography.headlineMd),
        const SizedBox(height: 4),
        Text('Summary of tenant parameters to deploy into the enclave.', style: CentriaTypography.bodySm),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CentriaColors.surfaceInset,
            borderRadius: CentriaRadii.componentRadius,
            border: Border.all(color: CentriaColors.structuralStroke),
          ),
          child: Column(
            children: [
              _summaryRow('Entity', _companyController.text),
              const Divider(height: 16),
              _summaryRow('Registration', _regNumberController.text),
              const Divider(height: 16),
              _summaryRow('Role Privilege', _selectedRole),
              const Divider(height: 16),
              _summaryRow('Ledger Proof', 'Merkle Block #1,048,592 Root Initialized'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CentriaTypography.labelSm.copyWith(color: CentriaColors.textMuted)),
        Flexible(
          child: Text(
            value,
            style: CentriaTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
