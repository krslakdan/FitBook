import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'user_account_insert_request.g.dart';

/// Mirrors `FitBook.Model.Requests.UserAccounts.UserAccountInsertRequest`.
@JsonSerializable()
class UserAccountInsertRequest implements ApiRequestBody {
  UserAccountInsertRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.password,
    required this.role,
    this.profileImageUrl,
    this.isActive = true,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String username;
  final String password;
  final String role;
  final String? profileImageUrl;
  final bool isActive;

  factory UserAccountInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$UserAccountInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserAccountInsertRequestToJson(this);
}
