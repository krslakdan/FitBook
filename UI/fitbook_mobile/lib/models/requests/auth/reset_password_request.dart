import 'package:json_annotation/json_annotation.dart';

import '../../common/api_request_body.dart';

part 'reset_password_request.g.dart';

@JsonSerializable()
class ResetPasswordRequest implements ApiRequestBody {
  ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}
