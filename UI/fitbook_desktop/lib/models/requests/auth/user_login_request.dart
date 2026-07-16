import 'package:json_annotation/json_annotation.dart';

import '../../common/api_request_body.dart';

part 'user_login_request.g.dart';

/// Mirrors `FitBook.Model.Requests.Auth.UserLoginRequest`.
@JsonSerializable()
class UserLoginRequest implements ApiRequestBody {
  UserLoginRequest({required this.username, required this.password});

  final String username;
  final String password;

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserLoginRequestToJson(this);
}
