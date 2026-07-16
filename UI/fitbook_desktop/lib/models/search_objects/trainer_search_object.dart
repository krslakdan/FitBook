import '../common/base_search_object.dart';

/// Mirrors `FitBook.Model.SearchObjects.TrainerSearchObject`.
class TrainerSearchObject extends BaseSearchObject {
  const TrainerSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.isActive,
    this.isAvailable,
  });

  final bool? isActive;
  final bool? isAvailable;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (isActive != null) params['isActive'] = isActive;
    if (isAvailable != null) params['isAvailable'] = isAvailable;
    return params;
  }
}
