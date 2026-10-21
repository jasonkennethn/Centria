import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import '../services/session_manager.dart';
import '../widgets/centria_ui.dart';
import '../widgets/skeleton.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SessionManager.splashAlreadyShown = true;
    SessionManager.currentPage = 'home';
    SessionManager.prefillEmail = null;
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
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Read cached user session from LocalStorage (instant/offline)
    final user = await LocalStorage.getUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _isLoading = false;
    });
    _animController.forward();
  }

  Future<void> _handleLogout() async {
    SessionManager.currentPage = 'login';
    SessionManager.prefillEmail = null;
    // Clear user session from offline storage
    await LocalStorage.logout();
    if (!mounted) return;

    // Navigate cleanly and directly to LoginScreen with ZERO splashscreen
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CentriaBackground(
      child: _isLoading
          // Skeleton loading while reading user profile from local storage
          ? const HomeScreenSkeleton()
          : Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand Logo Avatar with Glowing Ring
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: CentriaTheme.primaryCyan.withValues(alpha: 0.35),
                                  blurRadius: 32,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: CentriaTheme.primaryCyan.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Exact requirement title: "Welcome to Our Application !"
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                CentriaTheme.brandGradient.createShader(bounds),
                            child: const Text(
                              'Welcome to Our Application !',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // User Information Glass Card
                          CentriaGlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: CentriaTheme.primaryCyan.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: CentriaTheme.primaryCyan,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_user?['first_name'] ?? 'Centria'} ${_user?['last_name'] ?? 'User'}'.trim(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _user?['email'] ?? 'Verified Account',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white.withValues(alpha: 0.50),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  height: 1,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF00E676),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Session Active',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(alpha: 0.70),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Offline Synced',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: CentriaTheme.primaryCyan.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Sign Out Button (cleanly exits directly to LoginScreen with NO splashscreen)
                          SizedBox(
                            width: 170,
                            height: 48,
                            child: CentriaButton(
                              text: 'Sign Out',
                              isSecondary: true,
                              icon: Icons.logout_rounded,
                              onPressed: _handleLogout,
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
