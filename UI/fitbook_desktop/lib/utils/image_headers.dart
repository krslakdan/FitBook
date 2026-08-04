import '../providers/auth_session.dart';

Map<String, String>? authorizedImageHeaders() {
  final token = AuthSession.accessToken;
  if (token == null || token.isEmpty) return null;
  return {'Authorization': 'Bearer $token'};
}
