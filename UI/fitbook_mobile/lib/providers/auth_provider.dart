import 'dart:convert';

import '../models/requests/auth/forgot_password_request.dart';
import '../models/requests/auth/logout_request.dart';
import '../models/requests/auth/refresh_token_request.dart';
import '../models/requests/auth/reset_password_request.dart';
import '../models/requests/auth/user_login_request.dart';
import '../models/requests/auth/user_register_request.dart';
import '../models/responses/auth/refresh_token_response.dart';
import '../models/responses/auth/user_login_response.dart';
import 'auth_session.dart';
import 'base_provider.dart';

class AuthProvider extends BaseProvider {
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
    await AuthSession.persist();
    notifyListeners();
  }

  Future<void> register(UserRegisterRequest request) async {
    await apiPost('auth/register', body: request);
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await apiPost('auth/forgot-password', body: request);
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    await apiPost('auth/reset-password', body: request);
  }

  Future<void> logout() async {
    final refreshToken = AuthSession.refreshToken;
    if (refreshToken != null) {
      await _revokeServerSession(refreshToken);
    }
    await AuthSession.clear();
    notifyListeners();
  }

  Future<void> _revokeServerSession(String refreshToken) async {
    try {
      await apiPost(
        'auth/logout',
        body: LogoutRequest(refreshToken: refreshToken),
      );
    } on Exception {
      return;
    }
  }

  Future<bool> tryRestoreSession() async {
    await AuthSession.restore();
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
