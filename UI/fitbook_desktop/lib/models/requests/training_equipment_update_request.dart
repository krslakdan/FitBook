import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_equipment_update_request.g.dart';

@JsonSerializable()
class TrainingEquipmentUpdateRequest implements ApiRequestBody {
  TrainingEquipmentUpdateRequest({
    required this.isRequired,
    this.note,
    required this.trainingId,
    required this.equipmentId,
  });

  final bool isRequired;
  final String? note;
  final int trainingId;
  final int equipmentId;

  factory TrainingEquipmentUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingEquipmentUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingEquipmentUpdateRequestToJson(this);
}
