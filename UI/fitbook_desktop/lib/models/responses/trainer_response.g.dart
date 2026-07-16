// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainerResponse _$TrainerResponseFromJson(Map<String, dynamic> json) =>
    TrainerResponse(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      specialization: json['specialization'] as String,
      biography: json['biography'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool,
      isActive: json['isActive'] as bool,
      userAccountId: (json['userAccountId'] as num).toInt(),
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: json['updatedAtUtc'] == null
          ? null
          : DateTime.parse(json['updatedAtUtc'] as String),
    );

Map<String, dynamic> _$TrainerResponseToJson(TrainerResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fullName': instance.fullName,
      'specialization': instance.specialization,
      'biography': instance.biography,
      'imageUrl': instance.imageUrl,
      'isAvailable': instance.isAvailable,
      'isActive': instance.isActive,
      'userAccountId': instance.userAccountId,
      'createdAtUtc': instance.createdAtUtc.toIso8601String(),
      'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
    };
