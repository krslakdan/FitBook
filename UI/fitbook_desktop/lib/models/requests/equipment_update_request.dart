import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'equipment_update_request.g.dart';

@JsonSerializable()
class EquipmentUpdateRequest implements ApiRequestBody {
  EquipmentUpdateRequest({
    required this.name,
    required this.isActive,
  });

  final String name;
  final bool isActive;

  factory EquipmentUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$EquipmentUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EquipmentUpdateRequestToJson(this);
}
