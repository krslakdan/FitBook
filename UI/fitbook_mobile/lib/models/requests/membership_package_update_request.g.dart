// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_package_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipPackageUpdateRequest _$MembershipPackageUpdateRequestFromJson(
  Map<String, dynamic> json,
) => MembershipPackageUpdateRequest(
  name: json['name'] as String,
  durationDays: (json['durationDays'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  savingsAmount: (json['savingsAmount'] as num?)?.toDouble(),
  includedBenefits: json['includedBenefits'] as String,
  isActive: json['isActive'] as bool? ?? false,
);

Map<String, dynamic> _$MembershipPackageUpdateRequestToJson(
  MembershipPackageUpdateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'durationDays': instance.durationDays,
  'price': instance.price,
  'savingsAmount': instance.savingsAmount,
  'includedBenefits': instance.includedBenefits,
  'isActive': instance.isActive,
};
