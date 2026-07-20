import '../common/base_search_object.dart';

class EquipmentSearchObject extends BaseSearchObject {
  const EquipmentSearchObject({
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
