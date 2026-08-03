import 'dart:convert';

import '../models/responses/user_membership_response.dart';
import '../models/responses/user_membership_status_audit_response.dart';
import 'base_read_provider.dart';

class UserMembershipProvider extends BaseReadProvider<UserMembershipResponse> {
  UserMembershipProvider() : super('UserMemberships');

  @override
  UserMembershipResponse fromJson(Map<String, dynamic> json) =>
      UserMembershipResponse.fromJson(json);

  Future<List<UserMembershipStatusAuditResponse>> getStatusAudit(int id) async {
    final response = await apiGet('$endpoint/$id/audit');
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => UserMembershipStatusAuditResponse.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
