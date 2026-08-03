// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservations_report_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationsReportRequest _$ReservationsReportRequestFromJson(
  Map<String, dynamic> json,
) => ReservationsReportRequest(
  fromDate: DateTime.parse(json['fromDate'] as String),
  toDate: DateTime.parse(json['toDate'] as String),
);

Map<String, dynamic> _$ReservationsReportRequestToJson(
  ReservationsReportRequest instance,
) => <String, dynamic>{
  'fromDate': formatIsoDate(instance.fromDate),
  'toDate': formatIsoDate(instance.toDate),
};
