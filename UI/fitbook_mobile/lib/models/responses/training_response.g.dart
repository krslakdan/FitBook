// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingResponse _$TrainingResponseFromJson(Map<String, dynamic> json) =>
    TrainingResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      isActive: json['isActive'] as bool,
      trainingCategoryId: (json['trainingCategoryId'] as num).toInt(),
      trainingCategoryName: json['trainingCategoryName'] as String,
      difficultyLevelId: (json['difficultyLevelId'] as num).toInt(),
      difficultyLevelName: json['difficultyLevelName'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: json['updatedAtUtc'] == null
          ? null
          : DateTime.parse(json['updatedAtUtc'] as String),
    );

Map<String, dynamic> _$TrainingResponseToJson(TrainingResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'durationMinutes': instance.durationMinutes,
      'maxParticipants': instance.maxParticipants,
      'isActive': instance.isActive,
      'trainingCategoryId': instance.trainingCategoryId,
      'trainingCategoryName': instance.trainingCategoryName,
      'difficultyLevelId': instance.difficultyLevelId,
      'difficultyLevelName': instance.difficultyLevelName,
      'createdAtUtc': instance.createdAtUtc.toIso8601String(),
      'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
    };
