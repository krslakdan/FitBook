import '../common/base_search_object.dart';

class TrainerSearchObject extends BaseSearchObject {
  const TrainerSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.isActive,
    this.isAvailable,
    this.specializationId,
  });

  final bool? isActive;
  final bool? isAvailable;
  final int? specializationId;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (isActive != null) params['isActive'] = isActive;
    if (isAvailable != null) params['isAvailable'] = isAvailable;
    if (specializationId != null) params['specializationId'] = specializationId;
    return params;
  }
}
