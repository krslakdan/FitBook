import '../models/requests/user_account_admin_password_reset_request.dart';
import '../models/requests/user_account_change_own_password_request.dart';
import '../models/responses/user_account_response.dart';
import 'base_crud_provider.dart';

/// Talks to `UserAccountsController` (`api/useraccounts`).
class UserAccountProvider extends BaseCrudProvider<UserAccountResponse> {
  UserAccountProvider() : super('UserAccounts');

  @override
  UserAccountResponse fromJson(Map<String, dynamic> json) => UserAccountResponse.fromJson(json);

  Future<void> adminResetPassword(int id, UserAccountAdminPasswordResetRequest request) async {
    await apiPut('$endpoint/$id/password/admin-reset', body: request);
  }

  Future<void> changeOwnPassword(UserAccountChangeOwnPasswordRequest request) async {
    await apiPut('$endpoint/me/password', body: request);
  }
}
