// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_equipment_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingEquipmentInsertRequest _$TrainingEquipmentInsertRequestFromJson(
  Map<String, dynamic> json,
) => TrainingEquipmentInsertRequest(
  isRequired: json['isRequired'] as bool,
  note: json['note'] as String?,
  trainingId: (json['trainingId'] as num).toInt(),
  equipmentId: (json['equipmentId'] as num).toInt(),
);

Map<String, dynamic> _$TrainingEquipmentInsertRequestToJson(
  TrainingEquipmentInsertRequest instance,
) => <String, dynamic>{
  'isRequired': instance.isRequired,
  'note': instance.note,
  'trainingId': instance.trainingId,
  'equipmentId': instance.equipmentId,
};
