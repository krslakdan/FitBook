import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'user_account_update_request.g.dart';

/// Mirrors `FitBook.Model.Requests.UserAccounts.UserAccountUpdateRequest`.
/// Partial-update DTO — every field is optional, only send what changed.
/// Password is intentionally not here; use the dedicated password endpoints.
@JsonSerializable()
class UserAccountUpdateRequest implements ApiRequestBody {
  UserAccountUpdateRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.username,
    this.role,
    this.profileImageUrl,
    this.isActive,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? username;
  final String? role;
  final String? profileImageUrl;
  final bool? isActive;

  factory UserAccountUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserAccountUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserAccountUpdateRequestToJson(this);
}
