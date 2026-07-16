// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingInsertRequest _$TrainingInsertRequestFromJson(
  Map<String, dynamic> json,
) => TrainingInsertRequest(
  name: json['name'] as String,
  description: json['description'] as String,
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  isActive: json['isActive'] as bool,
  trainingCategoryId: (json['trainingCategoryId'] as num).toInt(),
  difficultyLevelId: (json['difficultyLevelId'] as num).toInt(),
);

Map<String, dynamic> _$TrainingInsertRequestToJson(
  TrainingInsertRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'durationMinutes': instance.durationMinutes,
  'maxParticipants': instance.maxParticipants,
  'isActive': instance.isActive,
  'trainingCategoryId': instance.trainingCategoryId,
  'difficultyLevelId': instance.difficultyLevelId,
};
