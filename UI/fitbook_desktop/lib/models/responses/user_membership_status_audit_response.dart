import 'package:json_annotation/json_annotation.dart';

import '../enums/membership_status.dart';

part 'user_membership_status_audit_response.g.dart';

@JsonSerializable()
class UserMembershipStatusAuditResponse {
  UserMembershipStatusAuditResponse({
    required this.id,
    required this.previousStatus,
    required this.newStatus,
    required this.changedAtUtc,
    this.reason,
    required this.changedByUserFullName,
  });

  final int id;
  final MembershipStatus previousStatus;
  final MembershipStatus newStatus;
  final DateTime changedAtUtc;
  final String? reason;
  final String changedByUserFullName;

  factory UserMembershipStatusAuditResponse.fromJson(Map<String, dynamic> json) =>
      _$UserMembershipStatusAuditResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserMembershipStatusAuditResponseToJson(this);
}
