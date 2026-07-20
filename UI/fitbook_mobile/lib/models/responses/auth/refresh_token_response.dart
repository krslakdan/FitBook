import 'package:json_annotation/json_annotation.dart';

part 'refresh_token_response.g.dart';

@JsonSerializable()
class RefreshTokenResponse {
  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtUtc,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAtUtc;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}
