import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'user_account_admin_password_reset_request.g.dart';

/// Mirrors `FitBook.Model.Requests.UserAccounts.UserAccountAdminPasswordResetRequest`.
@JsonSerializable()
class UserAccountAdminPasswordResetRequest implements ApiRequestBody {
  UserAccountAdminPasswordResetRequest({required this.newPassword});

  final String newPassword;

  factory UserAccountAdminPasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$UserAccountAdminPasswordResetRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserAccountAdminPasswordResetRequestToJson(this);
}
