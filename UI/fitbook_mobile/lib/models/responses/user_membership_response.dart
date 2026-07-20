import 'package:json_annotation/json_annotation.dart';

import '../enums/membership_status.dart';

part 'user_membership_response.g.dart';

@JsonSerializable()
class UserMembershipResponse {
  UserMembershipResponse({
    required this.id,
    required this.status,
    required this.startDateUtc,
    required this.endDateUtc,
    this.nextPaymentDateUtc,
    required this.isActive,
    required this.isPaid,
    required this.userAccountId,
    required this.userFirstName,
    required this.userLastName,
    required this.userEmail,
    required this.membershipPackageId,
    required this.packageName,
    required this.packagePrice,
    required this.packageDurationDays,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final MembershipStatus status;
  final DateTime startDateUtc;
  final DateTime endDateUtc;
  final DateTime? nextPaymentDateUtc;
  final bool isActive;
  final bool isPaid;
  final int userAccountId;
  final String userFirstName;
  final String userLastName;
  final String userEmail;
  final int membershipPackageId;
  final String packageName;
  final double packagePrice;
  final int packageDurationDays;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  String get userFullName => '$userFirstName $userLastName';

  factory UserMembershipResponse.fromJson(Map<String, dynamic> json) =>
      _$UserMembershipResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserMembershipResponseToJson(this);
}
