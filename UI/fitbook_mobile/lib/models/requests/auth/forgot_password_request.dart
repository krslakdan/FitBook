import 'package:json_annotation/json_annotation.dart';

import '../../common/api_request_body.dart';

part 'forgot_password_request.g.dart';

@JsonSerializable()
class ForgotPasswordRequest implements ApiRequestBody {
  ForgotPasswordRequest({required this.email});

  final String email;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}
