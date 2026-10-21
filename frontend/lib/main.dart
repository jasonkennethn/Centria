import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/local_storage.dart';
import 'services/session_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set seamless edge-to-edge transparent system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF090C16),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Read login state and tab session state synchronously/asynchronously before runApp
  final bool loggedIn = await LocalStorage.isLoggedIn();
  final bool splashAlreadyShown = SessionManager.splashAlreadyShown;
  final String? currentPage = SessionManager.currentPage;
  final String? prefillEmail = SessionManager.prefillEmail;

  runApp(CentriaApp(
    initialLoggedIn: loggedIn,
    splashAlreadyShown: splashAlreadyShown,
    initialPage: currentPage,
    initialPrefillEmail: prefillEmail,
  ));
}

class CentriaApp extends StatelessWidget {
  final bool initialLoggedIn;
  final bool splashAlreadyShown;
  final String? initialPage;
  final String? initialPrefillEmail;

  const CentriaApp({
    super.key,
    this.initialLoggedIn = false,
    this.splashAlreadyShown = false,
    this.initialPage,
    this.initialPrefillEmail,
  });

  Widget _resolveInitialScreen() {
    // If opening afresh (closed and reopened), show splashscreen once
    if (!splashAlreadyShown) {
      return const SplashScreen();
    }

    // On browser refresh / page reload in same session: bypass splashscreen completely
    if (initialLoggedIn) {
      return const HomeScreen();
    }

    if (initialPage == 'register' &&
        initialPrefillEmail != null &&
        initialPrefillEmail!.isNotEmpty) {
      return RegisterScreen(prefillEmail: initialPrefillEmail!);
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    final baseDarkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF090C16),
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00D2FF),
        secondary: Color(0xFF7C4DFF),
        surface: Color(0xFF0F1527),
      ),
    );

    return MaterialApp(
      title: 'Centria',
      debugShowCheckedModeBanner: false,
      theme: baseDarkTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(baseDarkTheme.textTheme),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: _resolveInitialScreen(),
    );
  }
}
