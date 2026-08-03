// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_status_audit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationStatusAuditResponse _$ReservationStatusAuditResponseFromJson(
  Map<String, dynamic> json,
) => ReservationStatusAuditResponse(
  id: (json['id'] as num).toInt(),
  previousStatus: $enumDecode(
    _$ReservationStatusEnumMap,
    json['previousStatus'],
  ),
  newStatus: $enumDecode(_$ReservationStatusEnumMap, json['newStatus']),
  changedAtUtc: DateTime.parse(json['changedAtUtc'] as String),
  reason: json['reason'] as String?,
  changedByUserFullName: json['changedByUserFullName'] as String,
);

Map<String, dynamic> _$ReservationStatusAuditResponseToJson(
  ReservationStatusAuditResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'previousStatus': _$ReservationStatusEnumMap[instance.previousStatus]!,
  'newStatus': _$ReservationStatusEnumMap[instance.newStatus]!,
  'changedAtUtc': instance.changedAtUtc.toIso8601String(),
  'reason': instance.reason,
  'changedByUserFullName': instance.changedByUserFullName,
};

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 1,
  ReservationStatus.confirmed: 2,
  ReservationStatus.cancelled: 3,
  ReservationStatus.completed: 4,
};
