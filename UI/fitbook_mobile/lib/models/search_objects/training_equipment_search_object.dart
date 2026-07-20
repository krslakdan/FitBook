import '../common/base_search_object.dart';

class TrainingEquipmentSearchObject extends BaseSearchObject {
  const TrainingEquipmentSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.trainingId,
  });

  final int? trainingId;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (trainingId != null) params['trainingId'] = trainingId;
    return params;
  }
}
