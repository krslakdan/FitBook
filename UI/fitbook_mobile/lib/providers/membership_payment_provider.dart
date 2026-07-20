import '../models/responses/membership_payment_response.dart';
import 'base_read_provider.dart';

class MembershipPaymentProvider extends BaseReadProvider<MembershipPaymentResponse> {
  MembershipPaymentProvider() : super('MembershipPayments');

  @override
  MembershipPaymentResponse fromJson(Map<String, dynamic> json) =>
      MembershipPaymentResponse.fromJson(json);
}
