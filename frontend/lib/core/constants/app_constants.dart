class AppConstants {
  static const String appName = 'Centria';
  static const String appTagline = 'The AI-Enabled Company Operating System';

  // Production Backend URL (Render)
  static const String defaultBackendUrl = 'https://centria-enterprise.onrender.com';

  // Local development fallback
  static const String localBackendUrl = 'http://127.0.0.1:8000';

  // Active Base URL
  static String baseUrl = defaultBackendUrl;

  // Frontend Hosting URL (Vercel)
  static const String frontendUrl = 'https://centria-enterprise.vercel.app';
  static const String privacyPolicyUrl = '$frontendUrl/privacy-policy';
  static const String termsOfServiceUrl = '$frontendUrl/terms-of-service';
  static const String contactEmail = 'support@celarox.com';
}
