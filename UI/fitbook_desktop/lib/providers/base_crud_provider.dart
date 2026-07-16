import 'dart:convert';

import '../models/common/api_request_body.dart';
import 'base_read_provider.dart';

abstract class BaseCrudProvider<T> extends BaseReadProvider<T> {
  BaseCrudProvider(super.endpoint);

  Future<T> insert(ApiRequestBody request) async {
    final response = await apiPost(endpoint, body: request);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return fromJson(decoded);
  }

  Future<T> update(int id, ApiRequestBody request) async {
    final response = await apiPut('$endpoint/$id', body: request);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return fromJson(decoded);
  }

  Future<void> remove(int id) async {
    await apiDelete('$endpoint/$id');
  }
}
