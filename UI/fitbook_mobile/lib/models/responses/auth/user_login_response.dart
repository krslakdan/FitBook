import 'package:json_annotation/json_annotation.dart';

part 'user_login_response.g.dart';

@JsonSerializable()
class UserLoginResponse {
  UserLoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpiresAtUtc,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime refreshTokenExpiresAtUtc;

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$UserLoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginResponseToJson(this);
}
