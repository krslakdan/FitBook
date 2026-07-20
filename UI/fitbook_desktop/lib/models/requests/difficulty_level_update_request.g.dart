// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_level_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DifficultyLevelUpdateRequest _$DifficultyLevelUpdateRequestFromJson(
  Map<String, dynamic> json,
) => DifficultyLevelUpdateRequest(
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$DifficultyLevelUpdateRequestToJson(
  DifficultyLevelUpdateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};
