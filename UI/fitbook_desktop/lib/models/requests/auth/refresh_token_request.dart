import 'package:json_annotation/json_annotation.dart';

import '../../common/api_request_body.dart';

part 'refresh_token_request.g.dart';

/// Mirrors `FitBook.Model.Requests.Auth.RefreshTokenRequest`.
@JsonSerializable()
class RefreshTokenRequest implements ApiRequestBody {
  RefreshTokenRequest({required this.refreshToken});

  final String refreshToken;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}
