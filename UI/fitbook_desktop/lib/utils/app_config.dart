class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5121/api',
  );

  /// Osnovni URL servera bez `/api` sufiksa — koristi se za statičke
  /// datoteke (slike iz wwwroot/uploads).
  static String get serverBaseUrl {
    final base = apiBaseUrl.endsWith('/') ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) : apiBaseUrl;
    return base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
  }

  /// Pretvara relativni URL slike ("uploads/...") u apsolutni, ili vraća
  /// null ako slika nije postavljena.
  static String? absoluteFileUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return null;
    if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) return relativeUrl;
    final clean = relativeUrl.startsWith('/') ? relativeUrl.substring(1) : relativeUrl;
    return '$serverBaseUrl/$clean';
  }
}
