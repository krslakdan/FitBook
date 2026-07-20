// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_category_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingCategoryInsertRequest _$TrainingCategoryInsertRequestFromJson(
  Map<String, dynamic> json,
) => TrainingCategoryInsertRequest(
  name: json['name'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$TrainingCategoryInsertRequestToJson(
  TrainingCategoryInsertRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'isActive': instance.isActive,
};
