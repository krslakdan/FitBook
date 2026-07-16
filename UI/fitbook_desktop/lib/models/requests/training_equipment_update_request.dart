import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_equipment_update_request.g.dart';

@JsonSerializable()
class TrainingEquipmentUpdateRequest implements ApiRequestBody {
  TrainingEquipmentUpdateRequest({
    required this.name,
    required this.isRequired,
    this.note,
    required this.trainingId,
  });

  final String name;
  final bool isRequired;
  final String? note;
  final int trainingId;

  factory TrainingEquipmentUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingEquipmentUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingEquipmentUpdateRequestToJson(this);
}
