import 'package:json_annotation/json_annotation.dart';

part 'user_login_response.g.dart';

/// Mirrors `FitBook.Model.Responses.Auth.UserLoginResponse`.
@JsonSerializable()
class UserLoginResponse {
  UserLoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtUtc,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAtUtc;

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$UserLoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginResponseToJson(this);
}
