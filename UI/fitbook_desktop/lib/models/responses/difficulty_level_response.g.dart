// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_level_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DifficultyLevelResponse _$DifficultyLevelResponseFromJson(
  Map<String, dynamic> json,
) => DifficultyLevelResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$DifficultyLevelResponseToJson(
  DifficultyLevelResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};
