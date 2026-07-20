// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HallResponse _$HallResponseFromJson(Map<String, dynamic> json) => HallResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  capacity: (json['capacity'] as num).toInt(),
  locationDescription: json['locationDescription'] as String?,
  isActive: json['isActive'] as bool,
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$HallResponseToJson(HallResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capacity': instance.capacity,
      'locationDescription': instance.locationDescription,
      'isActive': instance.isActive,
      'createdAtUtc': instance.createdAtUtc.toIso8601String(),
      'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
    };
