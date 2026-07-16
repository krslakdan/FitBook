import 'dart:convert';

/// Thrown by [BaseProvider] whenever the API returns a non-success status.
/// Carries the human-readable message the backend produced (see
/// `FitBook.WebAPI/Filters/ExceptionFilter.cs`) so screens can show it
/// directly instead of a generic "something went wrong".
class ApiClientException implements Exception {
  ApiClientException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thrown when the API responds 401 and the access token could not be
/// refreshed (or there was no session to refresh). Screens should catch
/// this specifically and navigate back to the login screen.
class UnauthorizedException extends ApiClientException {
  UnauthorizedException([super.message = 'Sesija je istekla. Prijavite se ponovo.'])
    : super(statusCode: 401);
}

/// Parses the `{ message, errors }` error body FitBook's `ExceptionFilter`
/// always produces into a single human-readable string.
class ApiErrorParser {
  ApiErrorParser._();

  static String? messageFromBody(String body) {
    if (body.isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      // `errors` carries the specific, actionable detail (field-level
      // validation messages, the business rule that failed, etc.); `message`
      // is often just a generic summary of the same thing ("Validacija nije
      // uspjela."), so prefer errors and only fall back to message.
      final detail = _flattenErrors(decoded['errors']);
      if (detail != null) return detail;

      final message = decoded['message'];
      return message is String && message.isNotEmpty ? message : null;
    } catch (_) {
      return null;
    }
  }

  static String? _flattenErrors(dynamic errors) {
    if (errors is! Map) return null;

    final messages = <String>[];
    for (final value in errors.values) {
      if (value is List) {
        messages.addAll(value.whereType<String>());
      } else if (value is String) {
        messages.add(value);
      }
    }

    return messages.isEmpty ? null : messages.join(' ');
  }
}
