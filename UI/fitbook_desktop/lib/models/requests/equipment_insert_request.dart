import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'equipment_insert_request.g.dart';

@JsonSerializable()
class EquipmentInsertRequest implements ApiRequestBody {
  EquipmentInsertRequest({
    required this.name,
    required this.isActive,
  });

  final String name;
  final bool isActive;

  factory EquipmentInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$EquipmentInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EquipmentInsertRequestToJson(this);
}
