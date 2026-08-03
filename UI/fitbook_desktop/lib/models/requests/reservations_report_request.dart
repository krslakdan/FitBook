import 'package:json_annotation/json_annotation.dart';

import '../../utils/formatters.dart';
import '../common/api_request_body.dart';

part 'reservations_report_request.g.dart';

@JsonSerializable()
class ReservationsReportRequest implements ApiRequestBody {
  ReservationsReportRequest({required this.fromDate, required this.toDate});

  @JsonKey(toJson: formatIsoDate)
  final DateTime fromDate;

  @JsonKey(toJson: formatIsoDate)
  final DateTime toDate;

  factory ReservationsReportRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationsReportRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationsReportRequestToJson(this);
}
