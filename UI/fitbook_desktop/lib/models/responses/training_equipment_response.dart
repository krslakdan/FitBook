import 'package:json_annotation/json_annotation.dart';

part 'training_equipment_response.g.dart';

@JsonSerializable()
class TrainingEquipmentResponse {
  TrainingEquipmentResponse({
    required this.id,
    required this.isRequired,
    this.note,
    required this.trainingId,
    required this.equipmentId,
    required this.equipmentName,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final bool isRequired;
  final String? note;
  final int trainingId;
  final int equipmentId;
  final String equipmentName;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory TrainingEquipmentResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainingEquipmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingEquipmentResponseToJson(this);
}
