import '../common/base_search_object.dart';

/// Mirrors `FitBook.Model.SearchObjects.MembershipPackageSearchObject`.
class MembershipPackageSearchObject extends BaseSearchObject {
  const MembershipPackageSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.isActive,
    this.includeDeleted = false,
    this.includeInactive = false,
  });

  final bool? isActive;
  final bool includeDeleted;
  final bool includeInactive;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (isActive != null) params['isActive'] = isActive;
    if (includeDeleted) params['includeDeleted'] = includeDeleted;
    if (includeInactive) params['includeInactive'] = includeInactive;
    return params;
  }
}
