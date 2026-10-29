import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/screens/splash_screen.dart';
import 'package:centria/screens/homepage_screen.dart';
import 'package:centria/screens/app_shell.dart';
import 'package:centria/services/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenSplash = prefs.getBool('centria_has_seen_splash') ?? false;
  await AuthState().init();

  runApp(CentriaApp(hasSeenSplash: hasSeenSplash));
}

class CentriaApp extends StatelessWidget {
  final bool hasSeenSplash;
  const CentriaApp({super.key, this.hasSeenSplash = false});

  @override
  Widget build(BuildContext context) {
    final String startRoute = !hasSeenSplash
        ? '/splash'
        : (AuthState().isAuthenticated ? '/dashboard' : '/');

    return MaterialApp(
      title: 'Centria — Company work, connected',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: startRoute,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const HomepageScreen(),
        '/dashboard': (context) => const AppShell(initialIndex: 0),
        '/projects': (context) => const AppShell(initialIndex: 1),
        '/tasks': (context) => const AppShell(initialIndex: 2),
        '/knowledge': (context) => const AppShell(initialIndex: 3),
        '/approvals': (context) => const AppShell(initialIndex: 4),
        '/admin': (context) => const AppShell(initialIndex: 5),
      },
    );
  }
}

