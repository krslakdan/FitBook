import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'hall_update_request.g.dart';

@JsonSerializable()
class HallUpdateRequest implements ApiRequestBody {
  HallUpdateRequest({
    required this.name,
    required this.capacity,
    this.locationDescription,
    required this.isActive,
  });

  final String name;
  final int capacity;
  final String? locationDescription;
  final bool isActive;

  factory HallUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$HallUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HallUpdateRequestToJson(this);
}
