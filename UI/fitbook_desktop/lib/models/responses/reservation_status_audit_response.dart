import 'package:json_annotation/json_annotation.dart';

import '../enums/reservation_status.dart';

part 'reservation_status_audit_response.g.dart';

@JsonSerializable()
class ReservationStatusAuditResponse {
  ReservationStatusAuditResponse({
    required this.id,
    required this.previousStatus,
    required this.newStatus,
    required this.changedAtUtc,
    this.reason,
    required this.changedByUserFullName,
  });

  final int id;
  final ReservationStatus previousStatus;
  final ReservationStatus newStatus;
  final DateTime changedAtUtc;
  final String? reason;
  final String changedByUserFullName;

  factory ReservationStatusAuditResponse.fromJson(Map<String, dynamic> json) =>
      _$ReservationStatusAuditResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationStatusAuditResponseToJson(this);
}
