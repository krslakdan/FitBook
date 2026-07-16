import 'package:shared_preferences/shared_preferences.dart';

/// Holds the current authentication session (in-memory + persisted via
/// `shared_preferences`) and is shared between [AuthProvider] (which owns
/// writing to it — login/refresh/logout) and `BaseProvider` (which only
/// reads the access token and can trigger a refresh through [tryRefresh]).
///
/// Splitting this out of `AuthProvider` keeps the base HTTP layer able to
/// react to an expired token without importing the concrete auth provider
/// (which itself depends on the base HTTP layer to make its own calls).
class AuthSession {
  AuthSession._();

  static const _accessTokenKey = 'fitbook_access_token';
  static const _refreshTokenKey = 'fitbook_refresh_token';

  static String? accessToken;
  static String? refreshToken;

  /// Registered by [AuthProvider] on construction. Performs a real
  /// `POST /auth/refresh` call and updates this session on success.
  static Future<bool> Function()? refreshHandler;

  static Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken == null || refreshToken == null) {
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      return;
    }
    await prefs.setString(_accessTokenKey, accessToken!);
    await prefs.setString(_refreshTokenKey, refreshToken!);
  }

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_accessTokenKey);
    refreshToken = prefs.getString(_refreshTokenKey);
  }

  /// Clears the session immediately (synchronously, before the first
  /// `await`) so callers that don't await this still see a logged-out state
  /// right away; persistence to disk finishes in the background.
  static Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    await persist();
  }

  static Future<bool> tryRefresh() async {
    final handler = refreshHandler;
    if (handler == null) return false;
    return handler();
  }
}
