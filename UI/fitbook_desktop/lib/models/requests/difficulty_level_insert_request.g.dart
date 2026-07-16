// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_level_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DifficultyLevelInsertRequest _$DifficultyLevelInsertRequestFromJson(
  Map<String, dynamic> json,
) => DifficultyLevelInsertRequest(
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$DifficultyLevelInsertRequestToJson(
  DifficultyLevelInsertRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};
