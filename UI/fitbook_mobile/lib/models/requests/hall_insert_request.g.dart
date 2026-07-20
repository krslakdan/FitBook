// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HallInsertRequest _$HallInsertRequestFromJson(Map<String, dynamic> json) =>
    HallInsertRequest(
      name: json['name'] as String,
      capacity: (json['capacity'] as num).toInt(),
      locationDescription: json['locationDescription'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$HallInsertRequestToJson(HallInsertRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'capacity': instance.capacity,
      'locationDescription': instance.locationDescription,
      'isActive': instance.isActive,
    };
