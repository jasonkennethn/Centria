import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/screens/splash_screen.dart';
import 'package:centria/screens/homepage_screen.dart';
import 'package:centria/screens/app_shell.dart';
import 'package:centria/services/auth_state.dart';

void main() async {
  // Use path URL strategy for clean URLs (e.g. site.com/dashboard instead of site.com/#/dashboard)
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    // Clear legacy persistent key so splash screen displays on each fresh browser launch
    await prefs.remove('centria_has_seen_splash');
  } catch (_) {}
  await AuthState().init();

  runApp(const CentriaApp());
}

class CentriaApp extends StatelessWidget {
  const CentriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centria — AI-Powered Company Operating System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        final raw = settings.name ?? '/';
        final uri = Uri.parse(raw);
        var path = uri.path.trim();
        if (path.endsWith('/') && path.length > 1) {
          path = path.substring(0, path.length - 1);
        }

        switch (path) {
          case '/dashboard':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AppShell(initialIndex: 0),
            );
          case '/projects':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AppShell(initialIndex: 1),
            );
          case '/tasks':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AppShell(initialIndex: 2),
            );
          case '/knowledge':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AppShell(initialIndex: 3),
            );
          case '/approvals':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AppShell(initialIndex: 4),
            );
          case '/admin':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AppShell(initialIndex: 5),
            );
          case '/splash':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SplashScreen(),
            );
          case '/':
          default:
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const HomepageScreen(),
            );
        }
      },
    );
  }
}

