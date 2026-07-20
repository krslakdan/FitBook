import '../common/base_search_object.dart';
import '../enums/membership_status.dart';

class MembershipSearchObject extends BaseSearchObject {
  const MembershipSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.userAccountId,
    this.membershipPackageId,
    this.status,
    this.activeFromUtc,
    this.activeToUtc,
  });

  final int? userAccountId;
  final int? membershipPackageId;
  final MembershipStatus? status;
  final DateTime? activeFromUtc;
  final DateTime? activeToUtc;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (userAccountId != null) params['userAccountId'] = userAccountId;
    if (membershipPackageId != null) {
      params['membershipPackageId'] = membershipPackageId;
    }
    if (status != null) params['status'] = status!.value;
    if (activeFromUtc != null) {
      params['activeFromUtc'] = activeFromUtc!.toIso8601String();
    }
    if (activeToUtc != null) params['activeToUtc'] = activeToUtc!.toIso8601String();
    return params;
  }
}
