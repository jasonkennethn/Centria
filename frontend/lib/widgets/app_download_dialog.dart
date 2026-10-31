import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;
import 'package:centria/theme/app_theme.dart';

enum DetectedMobileOS { android, ios, none }

DetectedMobileOS getDetectedMobileOS([BuildContext? context]) {
  if (kIsWeb) {
    try {
      final userAgent = web.window.navigator.userAgent.toLowerCase();
      if (userAgent.contains('android')) {
        return DetectedMobileOS.android;
      }
      if (userAgent.contains('iphone') ||
          userAgent.contains('ipad') ||
          userAgent.contains('ipod')) {
        return DetectedMobileOS.ios;
      }
    } catch (_) {}
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return DetectedMobileOS.android;
  }
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return DetectedMobileOS.ios;
  }

  // Responsive mobile viewport (< 860px)
  if (context != null) {
    final width = MediaQuery.of(context).size.width;
    if (width < 860) {
      return DetectedMobileOS.android;
    }
  }

  return DetectedMobileOS.none;
}

void triggerAppDownload(DetectedMobileOS os) {
  const version = '1.0.0';
  final filename = os == DetectedMobileOS.android
      ? 'centria_v$version.apk'
      : 'centria_v$version.ipa';

  if (kIsWeb) {
    try {
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = '/$filename';
      anchor.download = filename;
      anchor.target = '_blank';
      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
    } catch (e) {
      debugPrint('App download trigger error: $e');
    }
  }
}

class AppDownloadHoverDialog extends StatefulWidget {
  const AppDownloadHoverDialog({super.key});

  @override
  State<AppDownloadHoverDialog> createState() => _AppDownloadHoverDialogState();
}

class _AppDownloadHoverDialogState extends State<AppDownloadHoverDialog>
    with SingleTickerProviderStateMixin {
  bool _dismissed = false;
  bool _downloading = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final os = getDetectedMobileOS(context);

    // STRICT: Only show on Android or iOS
    if (os == DetectedMobileOS.none || _dismissed) {
      return const SizedBox.shrink();
    }

    final isAndroid = os == DetectedMobileOS.android;
    final osName = isAndroid ? 'Android' : 'iOS';
    final fileType = isAndroid ? 'APK' : 'IPA';

    return SafeArea(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.95),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Centria App Squircle Icon
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              isAndroid ? Icons.android : Icons.apple,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Centria for $osName',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: AppColors.ink,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.teal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    fileType,
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Native experience • v1.0.0',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Apple-style GET / Download Pill Button
                      ElevatedButton(
                        onPressed: _downloading
                            ? null
                            : () async {
                                setState(() => _downloading = true);
                                triggerAppDownload(os);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Downloading centria_v1.0.0.${fileType.toLowerCase()}...',
                                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                                      ),
                                      backgroundColor: AppColors.teal,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                                await Future.delayed(const Duration(seconds: 2));
                                if (mounted) setState(() => _downloading = false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: const Size(0, 34),
                          shape: const StadiumBorder(),
                        ),
                        child: _downloading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.arrow_downward_rounded, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'GET',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(width: 4),
                      // Minimalist Close button
                      InkWell(
                        onTap: () => setState(() => _dismissed = true),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.muted,
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
      ),
    );
  }
}
