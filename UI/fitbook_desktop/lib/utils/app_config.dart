/// Central, single-source-of-truth application configuration.
///
/// [apiBaseUrl] is read once at compile time via `--dart-define=API_BASE_URL=...`
/// per the RSII submission requirements. Every provider must go through this
/// constant instead of defining its own `String.fromEnvironment` call.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5121/api',
  );
}
