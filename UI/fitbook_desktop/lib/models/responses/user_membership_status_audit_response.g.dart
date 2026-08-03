// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_membership_status_audit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMembershipStatusAuditResponse _$UserMembershipStatusAuditResponseFromJson(
  Map<String, dynamic> json,
) => UserMembershipStatusAuditResponse(
  id: (json['id'] as num).toInt(),
  previousStatus: $enumDecode(
    _$MembershipStatusEnumMap,
    json['previousStatus'],
  ),
  newStatus: $enumDecode(_$MembershipStatusEnumMap, json['newStatus']),
  changedAtUtc: DateTime.parse(json['changedAtUtc'] as String),
  reason: json['reason'] as String?,
  changedByUserFullName: json['changedByUserFullName'] as String,
);

Map<String, dynamic> _$UserMembershipStatusAuditResponseToJson(
  UserMembershipStatusAuditResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'previousStatus': _$MembershipStatusEnumMap[instance.previousStatus]!,
  'newStatus': _$MembershipStatusEnumMap[instance.newStatus]!,
  'changedAtUtc': instance.changedAtUtc.toIso8601String(),
  'reason': instance.reason,
  'changedByUserFullName': instance.changedByUserFullName,
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.pending: 1,
  MembershipStatus.active: 2,
  MembershipStatus.expired: 3,
  MembershipStatus.cancelled: 4,
};
