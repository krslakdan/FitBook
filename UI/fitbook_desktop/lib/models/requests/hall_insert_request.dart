import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'hall_insert_request.g.dart';

/// Mirrors `FitBook.Model.Requests.HallInsertRequest`.
@JsonSerializable()
class HallInsertRequest implements ApiRequestBody {
  HallInsertRequest({
    required this.name,
    required this.capacity,
    this.locationDescription,
    required this.isActive,
  });

  final String name;
  final int capacity;
  final String? locationDescription;
  final bool isActive;

  factory HallInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$HallInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HallInsertRequestToJson(this);
}
