import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_equipment_insert_request.g.dart';

@JsonSerializable()
class TrainingEquipmentInsertRequest implements ApiRequestBody {
  TrainingEquipmentInsertRequest({
    required this.name,
    required this.isRequired,
    this.note,
    required this.trainingId,
  });

  final String name;
  final bool isRequired;
  final String? note;
  final int trainingId;

  factory TrainingEquipmentInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingEquipmentInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingEquipmentInsertRequestToJson(this);
}
