import 'package:flutter/material.dart';
import 'package:centria/theme/app_theme.dart';
import 'package:centria/screens/splash_screen.dart';
import 'package:centria/screens/homepage_screen.dart';
import 'package:centria/screens/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CentriaApp());
}

class CentriaApp extends StatelessWidget {
  const CentriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centria — Company work, connected',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
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
