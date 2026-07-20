// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialization_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecializationUpdateRequest _$SpecializationUpdateRequestFromJson(
  Map<String, dynamic> json,
) => SpecializationUpdateRequest(
  name: json['name'] as String,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$SpecializationUpdateRequestToJson(
  SpecializationUpdateRequest instance,
) => <String, dynamic>{'name': instance.name, 'isActive': instance.isActive};
