import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import '../services/session_manager.dart';
import '../widgets/centria_ui.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String prefillEmail;
  const RegisterScreen({super.key, required this.prefillEmail});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _emailController;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SessionManager.splashAlreadyShown = true;
    SessionManager.currentPage = 'register';
    SessionManager.prefillEmail = widget.prefillEmail;
    _emailController = TextEditingController(text: widget.prefillEmail);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!await _hasInternet()) {
      if (!mounted) return;
      showCentriaSnack(
        context,
        message: 'Internet connection is required to create an account',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ApiService.register(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      // Save user session locally for offline capability
      await LocalStorage.saveUser(result['user']);

      if (!mounted) return;
      SessionManager.currentPage = 'home';
      SessionManager.prefillEmail = null;
      // Navigate cleanly to HomeScreen with ZERO splashscreen
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showCentriaSnack(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CentriaBackground(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Title / Heading
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        CentriaTheme.brandGradient.createShader(bounds),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Complete your details to join Centria',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.50),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Glassmorphic Registration Form
                  CentriaGlassCard(
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Prefilled & Locked Email (Non-editable)
                            CentriaLockedField(
                              label: 'Email (From Sign In)',
                              value: widget.prefillEmail,
                              prefixIcon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),

                            // 2. First Name
                            CentriaTextField(
                              controller: _firstNameController,
                              hintText: 'Enter Your First Name',
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.givenName],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'First name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // 3. Last Name
                            CentriaTextField(
                              controller: _lastNameController,
                              hintText: 'Enter Your Last Name',
                              prefixIcon: Icons.badge_outlined,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.familyName],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Last name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // 4. Password
                            CentriaTextField(
                              controller: _passwordController,
                              hintText: 'Enter Your Password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password is required';
                                }
                                if (val.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Confirm Password
                            CentriaTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Your Password',
                              prefixIcon: Icons.lock_reset_outlined,
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: _handleRegister,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (val != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Create Account Button (displays skeleton shimmer when loading)
                            CentriaButton(
                              text: 'Create Account',
                              isLoading: _loading,
                              onPressed: _loading ? null : _handleRegister,
                            ),
                            const SizedBox(height: 16),

                            // Back to Sign In
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  SessionManager.currentPage = 'login';
                                  // Cleanly pop back to LoginScreen with ZERO splashscreen
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                                label: Text(
                                  'Back to Sign In',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
