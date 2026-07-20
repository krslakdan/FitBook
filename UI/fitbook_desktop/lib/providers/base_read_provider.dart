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
}
