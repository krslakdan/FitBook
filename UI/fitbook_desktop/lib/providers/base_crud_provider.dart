import 'dart:convert';

import '../models/common/api_request_body.dart';
import 'base_read_provider.dart';

/// Full CRUD side of the provider hierarchy — mirrors the backend's
/// `BaseCRUDController<TResponse, TSearch, TInsertRequest, TUpdateRequest,
/// TService>`: adds `POST`, `PUT /{id}` and `DELETE /{id}` on top of
/// [BaseReadProvider]'s read operations.
///
/// [insert]/[update] take an [ApiRequestBody] — the typed request model
/// generated for that entity (e.g. `TrainingInsertRequest`) — rather than
/// `dynamic`.
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
