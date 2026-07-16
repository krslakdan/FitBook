import 'dart:convert';

import '../models/requests/reservation_cancel_request.dart';
import '../models/responses/reservation_response.dart';
import 'base_read_provider.dart';

/// Talks to `ReservationsController` (`api/reservations`). Extends
/// [BaseReadProvider] rather than [BaseCrudProvider]: the desktop admin app
/// only ever browses reservations and changes their status through the
/// dedicated confirm/cancel/complete endpoints (mirroring the backend's
/// centralized state-machine logic) — it never creates one (that's a mobile
/// self-service flow, `ReservationInsertRequest` isn't modeled here) nor
/// hard-deletes one (cancellation is the only "removal" the business logic
/// supports).
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
}
