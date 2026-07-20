import 'dart:convert';

import '../models/requests/user_membership_cancel_request.dart';
import '../models/requests/user_membership_insert_request.dart';
import '../models/responses/create_payment_intent_response.dart';
import '../models/responses/user_membership_response.dart';
import 'base_read_provider.dart';

class UserMembershipProvider extends BaseReadProvider<UserMembershipResponse> {
  UserMembershipProvider() : super('UserMemberships');

  @override
  UserMembershipResponse fromJson(Map<String, dynamic> json) =>
      UserMembershipResponse.fromJson(json);

  Future<UserMembershipResponse> create(UserMembershipInsertRequest request) async {
    final response = await apiPost(endpoint, body: request);
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<UserMembershipResponse> cancel(int id, UserMembershipCancelRequest request) async {
    final response = await apiPost('$endpoint/$id/cancel', body: request);
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<CreatePaymentIntentResponse> createPaymentIntent(int id) async {
    final response = await apiPost('$endpoint/$id/payment/intent');
    return CreatePaymentIntentResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
