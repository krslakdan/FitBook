// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_equipment_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingEquipmentUpdateRequest _$TrainingEquipmentUpdateRequestFromJson(
  Map<String, dynamic> json,
) => TrainingEquipmentUpdateRequest(
  name: json['name'] as String,
  isRequired: json['isRequired'] as bool,
  note: json['note'] as String?,
  trainingId: (json['trainingId'] as num).toInt(),
);

Map<String, dynamic> _$TrainingEquipmentUpdateRequestToJson(
  TrainingEquipmentUpdateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'isRequired': instance.isRequired,
  'note': instance.note,
  'trainingId': instance.trainingId,
};
