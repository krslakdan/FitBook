import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_equipment_insert_request.g.dart';

@JsonSerializable()
class TrainingEquipmentInsertRequest implements ApiRequestBody {
  TrainingEquipmentInsertRequest({
    required this.isRequired,
    this.note,
    required this.trainingId,
    required this.equipmentId,
  });

  final bool isRequired;
  final String? note;
  final int trainingId;
  final int equipmentId;

  factory TrainingEquipmentInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingEquipmentInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingEquipmentInsertRequestToJson(this);
}
