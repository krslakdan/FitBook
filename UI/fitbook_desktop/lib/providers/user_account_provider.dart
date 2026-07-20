import '../models/requests/user_account_admin_password_reset_request.dart';
import '../models/responses/user_account_response.dart';
import 'base_crud_provider.dart';

class UserAccountProvider extends BaseCrudProvider<UserAccountResponse> {
  UserAccountProvider() : super('UserAccounts');

  @override
  UserAccountResponse fromJson(Map<String, dynamic> json) => UserAccountResponse.fromJson(json);

  Future<void> adminResetPassword(int id, UserAccountAdminPasswordResetRequest request) async {
    await apiPut('$endpoint/$id/password/admin-reset', body: request);
  }
}
