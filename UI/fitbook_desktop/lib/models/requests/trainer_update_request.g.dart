// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerUpdateRequest _$TrainerUpdateRequestFromJson(
  Map<String, dynamic> json,
) => TrainerUpdateRequest(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  specialization: json['specialization'] as String,
  biography: json['biography'] as String?,
  imageUrl: json['imageUrl'] as String?,
  isAvailable: json['isAvailable'] as bool,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$TrainerUpdateRequestToJson(
  TrainerUpdateRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'specialization': instance.specialization,
  'biography': instance.biography,
  'imageUrl': instance.imageUrl,
  'isAvailable': instance.isAvailable,
  'isActive': instance.isActive,
};
