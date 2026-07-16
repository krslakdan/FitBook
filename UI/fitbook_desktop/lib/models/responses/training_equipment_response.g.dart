// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_equipment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingEquipmentResponse _$TrainingEquipmentResponseFromJson(
  Map<String, dynamic> json,
) => TrainingEquipmentResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  isRequired: json['isRequired'] as bool,
  note: json['note'] as String?,
  trainingId: (json['trainingId'] as num).toInt(),
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$TrainingEquipmentResponseToJson(
  TrainingEquipmentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isRequired': instance.isRequired,
  'note': instance.note,
  'trainingId': instance.trainingId,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};
