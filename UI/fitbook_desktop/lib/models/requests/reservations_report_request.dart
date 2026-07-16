import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'reservations_report_request.g.dart';

/// Mirrors `FitBook.Model.Requests.ReservationsReportRequest`.
@JsonSerializable()
class ReservationsReportRequest implements ApiRequestBody {
  ReservationsReportRequest({required this.fromUtc, required this.toUtc});

  final DateTime fromUtc;
  final DateTime toUtc;

  factory ReservationsReportRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationsReportRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationsReportRequestToJson(this);
}
