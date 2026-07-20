import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'reservation_insert_request.g.dart';

@JsonSerializable()
class ReservationInsertRequest implements ApiRequestBody {
  ReservationInsertRequest({required this.trainingTermId});

  final int trainingTermId;

  factory ReservationInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$ReservationInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReservationInsertRequestToJson(this);
}
