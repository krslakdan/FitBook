import 'dart:convert';

import '../models/requests/reservation_cancel_request.dart';
import '../models/responses/reservation_response.dart';
import '../models/responses/reservation_status_audit_response.dart';
import '../utils/api_client_exception.dart';
import 'base_read_provider.dart';

class ReservationProvider extends BaseReadProvider<ReservationResponse> {
  ReservationProvider() : super('Reservations');

  @override
  ReservationResponse fromJson(Map<String, dynamic> json) => ReservationResponse.fromJson(json);

  Future<ReservationResponse> confirm(int id) async {
    final response = await apiPost('$endpoint/$id/confirm');
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ReservationResponse> cancel(int id, ReservationCancelRequest request) async {
    final response = await apiPost('$endpoint/$id/cancel', body: request);
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ReservationResponse> complete(int id) async {
    final response = await apiPost('$endpoint/$id/complete');
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<ReservationStatusAuditResponse>> getStatusAudit(int id) async {
    final response = await apiGet('$endpoint/$id/audit');
    try {
      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => ReservationStatusAuditResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw ApiClientException('Historiju statusa nije moguće pročitati sa servera.');
    }
  }
}
