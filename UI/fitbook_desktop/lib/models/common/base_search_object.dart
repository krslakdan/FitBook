import 'package:flutter/foundation.dart';

/// Mirrors `FitBook.Model.SearchObjects.BaseSearchObject` — the paging/search
/// fields shared by every list endpoint's search object. Concrete search
/// objects extend this and add their own entity-specific filters.
///
/// Search objects are never deserialized from JSON (they're only ever sent
/// as query parameters on a GET), so unlike the request/response models
/// there is no `fromJson`/`json_serializable` involved here — just
/// [toQueryParameters].
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
