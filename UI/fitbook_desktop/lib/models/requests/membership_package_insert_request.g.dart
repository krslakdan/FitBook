// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_package_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipPackageInsertRequest _$MembershipPackageInsertRequestFromJson(
  Map<String, dynamic> json,
) => MembershipPackageInsertRequest(
  name: json['name'] as String,
  durationDays: (json['durationDays'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  savingsAmount: (json['savingsAmount'] as num?)?.toDouble(),
  includedBenefits: json['includedBenefits'] as String,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$MembershipPackageInsertRequestToJson(
  MembershipPackageInsertRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'durationDays': instance.durationDays,
  'price': instance.price,
  'savingsAmount': instance.savingsAmount,
  'includedBenefits': instance.includedBenefits,
  'isActive': instance.isActive,
};
