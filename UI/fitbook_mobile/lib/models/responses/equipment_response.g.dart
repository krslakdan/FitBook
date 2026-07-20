// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipmentResponse _$EquipmentResponseFromJson(Map<String, dynamic> json) =>
    EquipmentResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: json['updatedAtUtc'] == null
          ? null
          : DateTime.parse(json['updatedAtUtc'] as String),
    );

Map<String, dynamic> _$EquipmentResponseToJson(EquipmentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isActive': instance.isActive,
      'createdAtUtc': instance.createdAtUtc.toIso8601String(),
      'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
    };
