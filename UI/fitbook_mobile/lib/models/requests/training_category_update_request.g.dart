// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_category_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingCategoryUpdateRequest _$TrainingCategoryUpdateRequestFromJson(
  Map<String, dynamic> json,
) => TrainingCategoryUpdateRequest(
  name: json['name'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$TrainingCategoryUpdateRequestToJson(
  TrainingCategoryUpdateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'isActive': instance.isActive,
};
