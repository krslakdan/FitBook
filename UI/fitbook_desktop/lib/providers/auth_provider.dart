import 'dart:convert';

import '../models/requests/auth/logout_request.dart';
import '../models/requests/auth/refresh_token_request.dart';
import '../models/requests/auth/user_login_request.dart';
import '../models/responses/auth/refresh_token_response.dart';
import '../models/responses/auth/user_login_response.dart';
import '../utils/api_client_exception.dart';
import 'auth_session.dart';
import 'base_provider.dart';

class AuthProvider extends BaseProvider {
  static const _adminRole = 'Admin';

  AuthProvider() {
    AuthSession.refreshHandler = _performRefresh;
  }

  bool get isAuthenticated => AuthSession.accessToken != null;

  int? get currentUserId {
    final id = _claim('Id');
    return id == null ? null : int.tryParse(id);
  }

  String? get currentUsername => _claim('Username');
  String? get currentFirstName => _claim('FirstName');
  String? get currentLastName => _claim('LastName');
  String? get currentEmail => _claim('Email');
  String? get currentRole => _claim('Role');

  Future<void> login(UserLoginRequest request) async {
    final response = await apiPost('auth/login', body: request);
    final loginResponse = UserLoginResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    AuthSession.accessToken = loginResponse.accessToken;
    AuthSession.refreshToken = loginResponse.refreshToken;

    if (currentRole != _adminRole) {
      await logout();
      throw ApiClientException(
        'Pristup je dozvoljen samo administratorima.',
        statusCode: 403,
      );
    }

    await AuthSession.persist();
    notifyListeners();
  }

  Future<void> logout() async {
    final refreshToken = AuthSession.refreshToken;
    if (refreshToken != null) {
      try {
        await apiPost(
          'auth/logout',
          body: LogoutRequest(refreshToken: refreshToken),
        );
      } on Exception {
        // Best-effort: the local session is cleared below regardless, so an
        // unreachable server (or an already-expired token) shouldn't block
        // logging out on the client.
      }
    }
    await AuthSession.clear();
    notifyListeners();
  }

  Future<bool> tryRestoreSession() async {
    await AuthSession.restore();
    if (isAuthenticated && currentRole != _adminRole) {
      await AuthSession.clear();
    }
    notifyListeners();
    return isAuthenticated;
  }

  Future<bool> _performRefresh() async {
    final refreshToken = AuthSession.refreshToken;
    if (refreshToken == null) return false;

    try {
      final response = await apiPost(
        'auth/refresh',
        body: RefreshTokenRequest(refreshToken: refreshToken),
      );
      final refreshResponse = RefreshTokenResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      AuthSession.accessToken = refreshResponse.accessToken;
      AuthSession.refreshToken = refreshResponse.refreshToken;
      await AuthSession.persist();
      return true;
    } on Exception {
      return false;
    }
  }

  String? _claim(String name) {
    final token = AuthSession.accessToken;
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      return payload[name] as String?;
    } catch (_) {
      return null;
    }
  }
}
