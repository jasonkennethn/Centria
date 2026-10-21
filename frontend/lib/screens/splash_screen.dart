import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import '../services/session_manager.dart';
import '../widgets/centria_ui.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Snappy, Apple-smooth timing (360ms animation) - zero unnecessary latency
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.05, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Run authentication check in parallel with snappy display (zero lag)
    final stopwatch = Stopwatch()..start();
    final bool loggedIn = await LocalStorage.isLoggedIn();

    final remainingMs = 380 - stopwatch.elapsedMilliseconds;
    if (remainingMs > 0) {
      await Future.delayed(Duration(milliseconds: remainingMs));
    }

    if (!mounted) return;

    SessionManager.splashAlreadyShown = true;
    SessionManager.currentPage = loggedIn ? 'home' : 'login';

    final destination = loggedIn ? const HomeScreen() : const LoginScreen();

    // Smooth Apple-like crossfade into the destination screen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
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
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // High-fidelity glowing Logo
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: CentriaTheme.primaryCyan.withValues(alpha: 0.35),
                          blurRadius: 36,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: CentriaTheme.primaryPurple.withValues(alpha: 0.25),
                          blurRadius: 48,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Appearing effect brand title
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        CentriaTheme.brandGradient.createShader(bounds),
                    child: const Text(
                      'Centria',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 3.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtle subtitle
                  Text(
                    'ENTERPRISE PLATFORM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                      color: Colors.white.withValues(alpha: 0.40),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 3 Apple-smooth loading dots
                  const ThreeLoadingDots(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3 Apple-smooth pulsing loading dots
class ThreeLoadingDots extends StatefulWidget {
  const ThreeLoadingDots({super.key});

  @override
  State<ThreeLoadingDots> createState() => _ThreeLoadingDotsState();
}

class _ThreeLoadingDotsState extends State<ThreeLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value - (index * 0.20)) % 1.0;
        final wave = 1.0 - (progress * 2.0 - 1.0).abs();
        final scale = 0.75 + (0.45 * wave);
        final opacity = 0.30 + (0.70 * wave);

        return Opacity(
          opacity: opacity.clamp(0.25, 1.0),
          child: Transform.scale(
            scale: scale.clamp(0.70, 1.25),
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: CentriaTheme.buttonGradient,
                boxShadow: [
                  BoxShadow(
                    color: CentriaTheme.primaryCyan.withValues(alpha: 0.45),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0),
        _buildDot(1),
        _buildDot(2),
      ],
    );
  }
}
