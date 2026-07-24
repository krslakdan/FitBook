import '../common/base_search_object.dart';
import '../enums/reservation_status.dart';

class ReservationSearchObject extends BaseSearchObject {
  const ReservationSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.userAccountId,
    this.trainingTermId,
    this.trainerId,
    this.status,
    this.reservedFromUtc,
    this.reservedToUtc,
  });

  final int? userAccountId;
  final int? trainingTermId;
  final int? trainerId;
  final ReservationStatus? status;
  final DateTime? reservedFromUtc;
  final DateTime? reservedToUtc;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (userAccountId != null) params['userAccountId'] = userAccountId;
    if (trainingTermId != null) params['trainingTermId'] = trainingTermId;
    if (trainerId != null) params['trainerId'] = trainerId;
    if (status != null) params['status'] = status!.value;
    if (reservedFromUtc != null) {
      params['reservedFromUtc'] = reservedFromUtc!.toIso8601String();
    }
    if (reservedToUtc != null) params['reservedToUtc'] = reservedToUtc!.toIso8601String();
    return params;
  }
}
