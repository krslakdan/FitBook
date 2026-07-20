// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerInsertRequest _$TrainerInsertRequestFromJson(
  Map<String, dynamic> json,
) => TrainerInsertRequest(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  specializationId: (json['specializationId'] as num).toInt(),
  biography: json['biography'] as String?,
  imageUrl: json['imageUrl'] as String?,
  isAvailable: json['isAvailable'] as bool,
  isActive: json['isActive'] as bool,
  userAccountId: (json['userAccountId'] as num).toInt(),
);

Map<String, dynamic> _$TrainerInsertRequestToJson(
  TrainerInsertRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'specializationId': instance.specializationId,
  'biography': instance.biography,
  'imageUrl': instance.imageUrl,
  'isAvailable': instance.isAvailable,
  'isActive': instance.isActive,
  'userAccountId': instance.userAccountId,
};
