import 'package:json_annotation/json_annotation.dart';

import '../../common/api_request_body.dart';

part 'user_register_request.g.dart';

@JsonSerializable()
class UserRegisterRequest implements ApiRequestBody {
  UserRegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String username;
  final String password;

  factory UserRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRegisterRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserRegisterRequestToJson(this);
}
