import '../models/responses/user_membership_response.dart';
import 'base_read_provider.dart';

class UserMembershipProvider extends BaseReadProvider<UserMembershipResponse> {
  UserMembershipProvider() : super('UserMemberships');

  @override
  UserMembershipResponse fromJson(Map<String, dynamic> json) =>
      UserMembershipResponse.fromJson(json);
}
