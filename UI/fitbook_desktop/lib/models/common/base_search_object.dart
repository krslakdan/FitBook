import 'package:flutter/foundation.dart';

abstract class BaseSearchObject {
  const BaseSearchObject({this.page, this.pageSize, this.search, this.includeTotalCount});

  final int? page;
  final int? pageSize;
  final String? search;
  final bool? includeTotalCount;

  @mustCallSuper
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (pageSize != null) params['pageSize'] = pageSize;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (includeTotalCount != null) params['includeTotalCount'] = includeTotalCount;
    return params;
  }
}
