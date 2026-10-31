import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;
import 'package:centria/theme/app_theme.dart';

enum DetectedMobileOS { android, ios, none }

DetectedMobileOS getDetectedMobileOS() {
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

class _AppDownloadHoverDialogState extends State<AppDownloadHoverDialog> {
  bool _dismissed = false;
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    final os = getDetectedMobileOS();

    // STRICT: Only show on Android or iOS
    if (os == DetectedMobileOS.none || _dismissed) {
      return const SizedBox.shrink();
    }

    final isAndroid = os == DetectedMobileOS.android;
    final osName = isAndroid ? 'Android' : 'iOS';
    final fileType = isAndroid ? 'APK' : 'IPA';

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lime.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // App / OS badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lime.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  isAndroid ? Icons.android : Icons.apple,
                  color: AppColors.lime,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title & description
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Centria for $osName',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.lime.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'v1.0.0',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lime,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap below to install native $osName app',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFB4C1BA),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Download button
            ElevatedButton.icon(
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
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                            backgroundColor: AppColors.teal,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) setState(() => _downloading = false);
                    },
              icon: _downloading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink,
                      ),
                    )
                  : const Icon(Icons.download, size: 16),
              label: Text(
                'Download',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: AppColors.ink,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Dismiss button
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF8E9E96)),
              tooltip: 'Dismiss',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _dismissed = true),
            ),
          ],
        ),
      ),
    );
  }
}
