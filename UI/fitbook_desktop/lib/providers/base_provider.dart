import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/common/api_request_body.dart';
import '../utils/api_client_exception.dart';
import '../utils/app_config.dart';
import 'auth_session.dart';

/// Base of the whole provider hierarchy. Owns the raw HTTP plumbing shared
/// by every provider: building request URIs against [AppConfig.apiBaseUrl],
/// attaching the bearer token, turning a non-success response into a typed
/// [ApiClientException] with the backend's actual message, and transparently
/// retrying a request once after a successful token refresh on 401.
///
/// Deliberately has no generic type parameter — [BaseReadProvider] and
/// [BaseCrudProvider] build on top of this for resources that map onto a
/// single entity; [AuthProvider] and other one-off providers (reports,
/// recommendations) extend this directly.
abstract class BaseProvider with ChangeNotifier {
  @protected
  Map<String, String> createHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json', 'Accept': 'application/json'};
    final token = AuthSession.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @protected
  Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final base = AppConfig.apiBaseUrl.endsWith('/')
        ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
        : AppConfig.apiBaseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$base/$cleanPath');
    if (queryParameters == null || queryParameters.isEmpty) return uri;
    return uri.replace(
      queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  @protected
  Future<http.Response> apiGet(String path, {Map<String, dynamic>? queryParameters}) {
    return _send(() => http.get(buildUri(path, queryParameters), headers: createHeaders()));
  }

  @protected
  Future<http.Response> apiPost(String path, {ApiRequestBody? body}) {
    return _send(
      () => http.post(
        buildUri(path),
        headers: createHeaders(),
        body: body == null ? null : jsonEncode(body.toJson()),
      ),
    );
  }

  @protected
  Future<http.Response> apiPut(String path, {ApiRequestBody? body}) {
    return _send(
      () => http.put(
        buildUri(path),
        headers: createHeaders(),
        body: body == null ? null : jsonEncode(body.toJson()),
      ),
    );
  }

  @protected
  Future<http.Response> apiDelete(String path) {
    return _send(() => http.delete(buildUri(path), headers: createHeaders()));
  }

  Future<http.Response> _send(Future<http.Response> Function() request, {bool isRetry = false}) async {
    http.Response response;
    try {
      response = await request();
    } on http.ClientException {
      throw ApiClientException('Ne mogu se povezati sa serverom. Provjerite internet konekciju.');
    }

    if (response.statusCode == 401 && !isRetry) {
      final refreshed = await AuthSession.tryRefresh();
      if (refreshed) {
        return _send(request, isRetry: true);
      }
    }

    _validate(response);
    return response;
  }

  void _validate(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if (response.statusCode == 401) {
      // Fire-and-forget: nulls the in-memory tokens synchronously (before
      // the first `await` inside AuthSession.clear), persistence to disk
      // finishes in the background.
      AuthSession.clear();
      throw UnauthorizedException();
    }

    final parsed = ApiErrorParser.messageFromBody(response.body);
    if (response.statusCode >= 500) {
      throw ApiClientException(
        parsed ?? 'Greška na serveru. Molimo pokušajte ponovo kasnije.',
        statusCode: response.statusCode,
      );
    }
    throw ApiClientException(
      parsed ?? 'Zahtjev nije moguće obraditi. Molimo pokušajte ponovo.',
      statusCode: response.statusCode,
    );
  }
}
