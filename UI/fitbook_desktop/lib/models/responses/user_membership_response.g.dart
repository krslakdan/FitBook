// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_membership_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMembershipResponse _$UserMembershipResponseFromJson(
  Map<String, dynamic> json,
) => UserMembershipResponse(
  id: (json['id'] as num).toInt(),
  status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
  startDateUtc: DateTime.parse(json['startDateUtc'] as String),
  endDateUtc: DateTime.parse(json['endDateUtc'] as String),
  nextPaymentDateUtc: json['nextPaymentDateUtc'] == null
      ? null
      : DateTime.parse(json['nextPaymentDateUtc'] as String),
  isActive: json['isActive'] as bool,
  isPaid: json['isPaid'] as bool,
  userAccountId: (json['userAccountId'] as num).toInt(),
  userFirstName: json['userFirstName'] as String,
  userLastName: json['userLastName'] as String,
  userEmail: json['userEmail'] as String,
  membershipPackageId: (json['membershipPackageId'] as num).toInt(),
  packageName: json['packageName'] as String,
  packagePrice: (json['packagePrice'] as num).toDouble(),
  packageDurationDays: (json['packageDurationDays'] as num).toInt(),
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$UserMembershipResponseToJson(
  UserMembershipResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$MembershipStatusEnumMap[instance.status]!,
  'startDateUtc': instance.startDateUtc.toIso8601String(),
  'endDateUtc': instance.endDateUtc.toIso8601String(),
  'nextPaymentDateUtc': instance.nextPaymentDateUtc?.toIso8601String(),
  'isActive': instance.isActive,
  'isPaid': instance.isPaid,
  'userAccountId': instance.userAccountId,
  'userFirstName': instance.userFirstName,
  'userLastName': instance.userLastName,
  'userEmail': instance.userEmail,
  'membershipPackageId': instance.membershipPackageId,
  'packageName': instance.packageName,
  'packagePrice': instance.packagePrice,
  'packageDurationDays': instance.packageDurationDays,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.pending: 1,
  MembershipStatus.active: 2,
  MembershipStatus.expired: 3,
  MembershipStatus.cancelled: 4,
};
