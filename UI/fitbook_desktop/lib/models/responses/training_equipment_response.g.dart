// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_equipment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingEquipmentResponse _$TrainingEquipmentResponseFromJson(
  Map<String, dynamic> json,
) => TrainingEquipmentResponse(
  id: (json['id'] as num).toInt(),
  isRequired: json['isRequired'] as bool,
  note: json['note'] as String?,
  trainingId: (json['trainingId'] as num).toInt(),
  trainingName: json['trainingName'] as String,
  equipmentId: (json['equipmentId'] as num).toInt(),
  equipmentName: json['equipmentName'] as String,
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$TrainingEquipmentResponseToJson(
  TrainingEquipmentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'isRequired': instance.isRequired,
  'note': instance.note,
  'trainingId': instance.trainingId,
  'trainingName': instance.trainingName,
  'equipmentId': instance.equipmentId,
  'equipmentName': instance.equipmentName,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};
