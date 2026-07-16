import '../common/base_search_object.dart';

class UserSearchObject extends BaseSearchObject {
  const UserSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.name,
    this.email,
    this.username,
    this.role,
    this.isActive,
    this.includeDeleted = false,
  });

  final String? name;
  final String? email;
  final String? username;
  final String? role;
  final bool? isActive;
  final bool includeDeleted;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (name != null && name!.isNotEmpty) params['name'] = name;
    if (email != null && email!.isNotEmpty) params['email'] = email;
    if (username != null && username!.isNotEmpty) params['username'] = username;
    if (role != null && role!.isNotEmpty) params['role'] = role;
    if (isActive != null) params['isActive'] = isActive;
    if (includeDeleted) params['includeDeleted'] = includeDeleted;
    return params;
  }
}
