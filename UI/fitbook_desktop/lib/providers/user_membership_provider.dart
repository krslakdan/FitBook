import 'dart:convert';

import '../models/common/page_result.dart';
import '../models/responses/user_membership_response.dart';
import '../models/responses/user_membership_status_audit_response.dart';
import '../utils/api_client_exception.dart';
import 'base_read_provider.dart';

class UserMembershipProvider extends BaseReadProvider<UserMembershipResponse> {
  UserMembershipProvider() : super('UserMemberships');

  @override
  UserMembershipResponse fromJson(Map<String, dynamic> json) =>
      UserMembershipResponse.fromJson(json);

  Future<List<UserMembershipStatusAuditResponse>> getStatusAudit(int id, {int pageSize = 100}) async {
    final response = await apiGet(
      '$endpoint/$id/audit',
      queryParameters: {'page': 1, 'pageSize': pageSize},
    );
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return PageResult<UserMembershipStatusAuditResponse>.fromJson(
        decoded,
        (json) => UserMembershipStatusAuditResponse.fromJson(json as Map<String, dynamic>),
      ).items;
    } catch (_) {
      throw ApiClientException('Historiju statusa nije moguće pročitati sa servera.');
    }
  }
}
