import '../models/requests/user_account_change_own_password_request.dart';
import '../models/responses/user_account_response.dart';
import 'base_crud_provider.dart';

class UserAccountProvider extends BaseCrudProvider<UserAccountResponse> {
  UserAccountProvider() : super('UserAccounts');

  @override
  UserAccountResponse fromJson(Map<String, dynamic> json) => UserAccountResponse.fromJson(json);

  Future<void> changeOwnPassword(UserAccountChangeOwnPasswordRequest request) async {
    await apiPut('$endpoint/me/password', body: request);
  }
}
