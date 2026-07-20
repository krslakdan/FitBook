import 'dart:convert';

class ApiClientException implements Exception {
  ApiClientException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiClientException {
  UnauthorizedException([super.message = 'Sesija je istekla. Prijavite se ponovo.'])
    : super(statusCode: 401);
}

class ApiErrorParser {
  ApiErrorParser._();

  static String? messageFromBody(String body) {
    if (body.isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

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
