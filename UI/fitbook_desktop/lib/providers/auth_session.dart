import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  AuthSession._();

  static const _accessTokenKey = 'fitbook_access_token';
  static const _refreshTokenKey = 'fitbook_refresh_token';

  static String? accessToken;
  static String? refreshToken;

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
