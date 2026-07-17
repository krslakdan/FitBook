import '../common/base_search_object.dart';

class SpecializationSearchObject extends BaseSearchObject {
  const SpecializationSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.isActive,
  });

  final bool? isActive;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (isActive != null) params['isActive'] = isActive;
    return params;
  }
}
