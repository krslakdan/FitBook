class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5121/api',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51TsPeX2Fg2hb3c521Laj2FVq5zPonsha0mIKGoqetNrcEsLxtirpRF3r5JlgMTs93uhq1iGDKz5gX0M8jXhXUT1100qtXUy6pQ',
  );

  static String get serverBaseUrl {
    final base = apiBaseUrl.endsWith('/') ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) : apiBaseUrl;
    return base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
  }

  static String? absoluteFileUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return null;
    if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) return relativeUrl;
    final clean = relativeUrl.startsWith('/') ? relativeUrl.substring(1) : relativeUrl;
    return '$serverBaseUrl/$clean';
  }
}
