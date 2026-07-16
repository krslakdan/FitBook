import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'user_account_change_own_password_request.g.dart';

/// Mirrors `FitBook.Model.Requests.UserAccounts.UserAccountChangeOwnPasswordRequest`.
@JsonSerializable()
class UserAccountChangeOwnPasswordRequest implements ApiRequestBody {
  UserAccountChangeOwnPasswordRequest({required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;

  factory UserAccountChangeOwnPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$UserAccountChangeOwnPasswordRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserAccountChangeOwnPasswordRequestToJson(this);
}
