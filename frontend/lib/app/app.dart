import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class CentriaApp extends StatelessWidget {
  const CentriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Centria — Sovereign Company Operating System',
      debugShowCheckedModeBanner: false,
      theme: CentriaTheme.lightTheme,
      routerConfig: centriaRouter,
    );
  }
}
