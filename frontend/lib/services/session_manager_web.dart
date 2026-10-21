import 'package:web/web.dart' as web;

class SessionManager {
  static const _keySplash = 'centria_splash_shown';
  static const _keyPage = 'centria_current_page';
  static const _keyPrefillEmail = 'centria_prefill_email';

  static bool get splashAlreadyShown {
    try {
      return web.window.sessionStorage.getItem(_keySplash) == 'true';
    } catch (_) {
      return false;
    }
  }

  static set splashAlreadyShown(bool value) {
    try {
      if (value) {
        web.window.sessionStorage.setItem(_keySplash, 'true');
      } else {
        web.window.sessionStorage.removeItem(_keySplash);
      }
    } catch (_) {}
  }

  static String? get currentPage {
    try {
      return web.window.sessionStorage.getItem(_keyPage);
    } catch (_) {
      return null;
    }
  }

  static set currentPage(String? value) {
    try {
      if (value != null) {
        web.window.sessionStorage.setItem(_keyPage, value);
      } else {
        web.window.sessionStorage.removeItem(_keyPage);
      }
    } catch (_) {}
  }

  static String? get prefillEmail {
    try {
      return web.window.sessionStorage.getItem(_keyPrefillEmail);
    } catch (_) {
      return null;
    }
  }

  static set prefillEmail(String? value) {
    try {
      if (value != null) {
        web.window.sessionStorage.setItem(_keyPrefillEmail, value);
      } else {
        web.window.sessionStorage.removeItem(_keyPrefillEmail);
      }
    } catch (_) {}
  }
}
