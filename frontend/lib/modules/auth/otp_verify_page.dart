import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/api_service.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  final Function(String route, {dynamic arguments}) onNavigate;

  const OtpVerifyPage({super.key, required this.email, required this.onNavigate});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpController = TextEditingController();
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _handleVerify() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _api.verifyOtp(widget.email, code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (res.isSuccess) {
        final data = res.data;
        if (data['tokens'] != null) {
          final access = data['tokens']['access'];
          final refresh = data['tokens']['refresh'];
          final user = data['user'] ?? {};
          await _api.saveAuthTokens(access, refresh, user);
          widget.onNavigate('/genesis');
        } else {
          widget.onNavigate('/login');
        }
      } else {
        setState(() => _errorMessage = res.errorMessage ?? 'Verification failed.');
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final res = await _api.resendOtp(widget.email);

    if (mounted) {
      setState(() {
        _isResending = false;
        if (res.isSuccess) {
          _successMessage = 'A new 6-digit security code was dispatched via Brevo.';
        } else {
          _errorMessage = res.errorMessage ?? 'Failed to resend code.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withAlpha(80)),
                    ),
                    child: const Icon(Icons.mark_email_read_outlined, color: AppTheme.accent, size: 28),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verify Your Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit verification code from Centira <no-reply@celarox.com> to:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),

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

                if (_successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.success.withAlpha(80)),
                    ),
                    child: Text(_successMessage!, style: const TextStyle(color: AppTheme.success, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],

                const Text('6-Digit Security Code', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerify,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Verify & Launch Workspace', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: _isResending ? null : _handleResend,
                  child: _isResending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                      : const Text('Did not receive code? Resend via Brevo', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => widget.onNavigate('/login'),
                  child: const Center(
                    child: Text('← Return to Sign In', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
