import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import '../services/session_manager.dart';
import '../widgets/centria_ui.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SessionManager.splashAlreadyShown = true;
    SessionManager.currentPage = 'login';
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
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
    _passwordController.dispose();
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

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!await _hasInternet()) {
      if (!mounted) return;
      showCentriaSnack(
        context,
        message: 'Internet connection is required to sign in',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    try {
      // 1. Check if the user email exists in Neon DB
      final checkResult = await ApiService.checkEmail(email);

      if (checkResult['exists'] == true) {
        // 2. Existing user — authenticate
        try {
          final loginResult = await ApiService.login(email, password);
          await LocalStorage.saveUser(loginResult['user']);

          if (!mounted) return;
          SessionManager.currentPage = 'home';
          SessionManager.prefillEmail = null;
          Navigator.of(context).pushReplacement(
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
          );
        } catch (e) {
          if (!mounted) return;
          showCentriaSnack(
            context,
            message: e.toString().replaceFirst('Exception: ', ''),
            isError: true,
          );
        }
      } else {
        // 3. New user — automatically navigate to registration with email pre-filled
        if (!mounted) return;
        SessionManager.currentPage = 'register';
        SessionManager.prefillEmail = email;
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => RegisterScreen(prefillEmail: email),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 320),
          ),
        ).then((_) {
          // When popping back from RegisterScreen, reset currentPage to login
          SessionManager.currentPage = 'login';
        });
      }
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
    return PopScope(
      canPop: true,
      child: CentriaBackground(
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
                    // Brand Header
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: CentriaTheme.primaryCyan.withValues(alpha: 0.30),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ShaderMask(
                      shaderCallback: (bounds) =>
                          CentriaTheme.brandGradient.createShader(bounds),
                      child: const Text(
                        'Centria',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to access your enterprise portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.50),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Glassmorphic Input Card
                    CentriaGlassCard(
                      child: Form(
                        key: _formKey,
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Enter your credentials to continue',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email Input
                              CentriaTextField(
                                controller: _emailController,
                                hintText: 'Enter Your Email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!val.contains('@') || !val.contains('.')) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Input
                              CentriaTextField(
                                controller: _passwordController,
                                hintText: 'Enter Your Password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onEditingComplete: _handleLogin,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),

                              // Continue Button (displays skeleton loader during request)
                              CentriaButton(
                                text: 'Continue',
                                isLoading: _loading,
                                onPressed: _loading ? null : _handleLogin,
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
      ),
    );
  }
}
