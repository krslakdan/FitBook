import '../common/base_search_object.dart';
import '../enums/payment_status.dart';

class MembershipPaymentSearchObject extends BaseSearchObject {
  const MembershipPaymentSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.userAccountId,
    this.userMembershipId,
    this.status,
  });

  final int? userAccountId;
  final int? userMembershipId;
  final PaymentStatus? status;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (userAccountId != null) params['userAccountId'] = userAccountId;
    if (userMembershipId != null) params['userMembershipId'] = userMembershipId;
    if (status != null) params['status'] = status!.value;
    return params;
  }
}
