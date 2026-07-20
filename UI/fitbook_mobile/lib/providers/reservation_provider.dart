import 'dart:convert';

import '../models/requests/reservation_cancel_request.dart';
import '../models/requests/reservation_insert_request.dart';
import '../models/responses/reservation_response.dart';
import 'base_read_provider.dart';

class ReservationProvider extends BaseReadProvider<ReservationResponse> {
  ReservationProvider() : super('Reservations');

  @override
  ReservationResponse fromJson(Map<String, dynamic> json) => ReservationResponse.fromJson(json);

  Future<ReservationResponse> create(ReservationInsertRequest request) async {
    final response = await apiPost(endpoint, body: request);
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ReservationResponse> cancel(int id, ReservationCancelRequest request) async {
    final response = await apiPost('$endpoint/$id/cancel', body: request);
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
