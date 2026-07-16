// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservations_report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationsReportRequest _$ReservationsReportRequestFromJson(
  Map<String, dynamic> json,
) => ReservationsReportRequest(
  fromUtc: DateTime.parse(json['fromUtc'] as String),
  toUtc: DateTime.parse(json['toUtc'] as String),
);

Map<String, dynamic> _$ReservationsReportRequestToJson(
  ReservationsReportRequest instance,
) => <String, dynamic>{
  'fromUtc': instance.fromUtc.toIso8601String(),
  'toUtc': instance.toUtc.toIso8601String(),
};
