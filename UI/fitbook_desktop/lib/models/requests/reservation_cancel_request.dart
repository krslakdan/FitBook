import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'reservation_cancel_request.g.dart';

@JsonSerializable()
class ReservationCancelRequest implements ApiRequestBody {
  ReservationCancelRequest({required this.reason});

  final String reason;

  factory ReservationCancelRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationCancelRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationCancelRequestToJson(this);
}
