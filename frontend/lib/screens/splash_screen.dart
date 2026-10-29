import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/services/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _dotIndex = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();
    _dotTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (mounted) {
        setState(() {
          _dotIndex = (_dotIndex + 1) % 3;
        });
      }
    });

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // 0.6s splash duration as requested in spec
    await Future.delayed(const Duration(milliseconds: 600));
    await AuthState().init();

    if (!mounted) return;
    _dotTimer?.cancel();

    if (AuthState().isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      if (kIsWeb) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centria Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo.png',
                width: 72,
                height: 72,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('C', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Centria Name
            Text(
              'centria',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.2,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            // 3 Animated Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isActive = index == _dotIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 9 : 7,
                  height: isActive ? 9 : 7,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.teal : AppColors.line,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
