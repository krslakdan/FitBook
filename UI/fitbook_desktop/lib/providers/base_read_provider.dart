import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/common/base_search_object.dart';
import '../models/common/page_result.dart';
import 'base_provider.dart';

/// Read side of the provider hierarchy — mirrors the backend's
/// `BaseReadController<TResponse, TSearch, TService>`: `GET /{endpoint}`
/// (paged list) and `GET /{endpoint}/{id}`. Resources this app only ever
/// reads and changes through dedicated action endpoints rather than a
/// generic insert/update (e.g. [ReservationProvider]) extend this directly
/// instead of [BaseCrudProvider], so there's no `insert`/`update`/`remove`
/// method sitting around unused.
abstract class BaseReadProvider<T> extends BaseProvider {
  BaseReadProvider(this.endpoint);

  /// API resource segment, e.g. `'Trainings'` → `{apiBaseUrl}/Trainings`.
  final String endpoint;

  @protected
  T fromJson(Map<String, dynamic> json);

  Future<PageResult<T>> get({BaseSearchObject? filter}) async {
    final response = await apiGet(endpoint, queryParameters: filter?.toQueryParameters());
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PageResult<T>.fromJson(decoded, (json) => fromJson(json as Map<String, dynamic>));
  }

  Future<T> getById(int id) async {
    final response = await apiGet('$endpoint/$id');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return fromJson(decoded);
  }
}
