import '../common/base_search_object.dart';
import '../enums/training_term_status.dart';

/// Mirrors `FitBook.Model.SearchObjects.TrainingTermSearchObject`.
class TrainingTermSearchObject extends BaseSearchObject {
  const TrainingTermSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.trainingId,
    this.trainerId,
    this.hallId,
    this.status,
    this.startFromUtc,
    this.startToUtc,
    this.isActive,
  });

  final int? trainingId;
  final int? trainerId;
  final int? hallId;
  final TrainingTermStatus? status;
  final DateTime? startFromUtc;
  final DateTime? startToUtc;
  final bool? isActive;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (trainingId != null) params['trainingId'] = trainingId;
    if (trainerId != null) params['trainerId'] = trainerId;
    if (hallId != null) params['hallId'] = hallId;
    if (status != null) params['status'] = status!.value;
    if (startFromUtc != null) params['startFromUtc'] = startFromUtc!.toIso8601String();
    if (startToUtc != null) params['startToUtc'] = startToUtc!.toIso8601String();
    if (isActive != null) params['isActive'] = isActive;
    return params;
  }
}
