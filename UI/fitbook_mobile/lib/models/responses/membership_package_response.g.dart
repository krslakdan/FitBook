// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_package_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipPackageResponse _$MembershipPackageResponseFromJson(
  Map<String, dynamic> json,
) => MembershipPackageResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  durationDays: (json['durationDays'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  savingsAmount: (json['savingsAmount'] as num?)?.toDouble(),
  includedBenefits: json['includedBenefits'] as String,
  isActive: json['isActive'] as bool,
  isDeleted: json['isDeleted'] as bool,
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$MembershipPackageResponseToJson(
  MembershipPackageResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'durationDays': instance.durationDays,
  'price': instance.price,
  'savingsAmount': instance.savingsAmount,
  'includedBenefits': instance.includedBenefits,
  'isActive': instance.isActive,
  'isDeleted': instance.isDeleted,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};
