import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/common/base_search_object.dart';
import '../models/common/page_result.dart';
import 'base_provider.dart';

abstract class BaseReadProvider<T> extends BaseProvider {
  BaseReadProvider(this.endpoint);

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

  Future<List<T>> getAllPages({
    required BaseSearchObject Function(int page) filterForPage,
    required int Function(T item) idOf,
    int pageSize = 100,
    int maxPages = 50,
  }) async {
    final collected = <T>[];
    final seenIds = <int>{};

    for (var page = 1; page <= maxPages; page++) {
      final result = await get(filter: filterForPage(page));

      for (final item in result.items) {
        if (seenIds.add(idOf(item))) {
          collected.add(item);
        }
      }

      if (result.items.length < pageSize) {
        break;
      }
    }

    return collected;
  }
}
