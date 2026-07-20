// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_category_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingCategoryResponse _$TrainingCategoryResponseFromJson(
  Map<String, dynamic> json,
) => TrainingCategoryResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$TrainingCategoryResponseToJson(
  TrainingCategoryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'isActive': instance.isActive,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};
