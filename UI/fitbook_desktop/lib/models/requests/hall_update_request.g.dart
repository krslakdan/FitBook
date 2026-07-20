// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HallUpdateRequest _$HallUpdateRequestFromJson(Map<String, dynamic> json) =>
    HallUpdateRequest(
      name: json['name'] as String,
      capacity: (json['capacity'] as num).toInt(),
      locationDescription: json['locationDescription'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$HallUpdateRequestToJson(HallUpdateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'capacity': instance.capacity,
      'locationDescription': instance.locationDescription,
      'isActive': instance.isActive,
    };
