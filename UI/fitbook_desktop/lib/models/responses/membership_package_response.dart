import 'package:json_annotation/json_annotation.dart';

part 'membership_package_response.g.dart';

/// Mirrors `FitBook.Model.Responses.MembershipPackageResponse`.
@JsonSerializable()
class MembershipPackageResponse {
  MembershipPackageResponse({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    this.savingsAmount,
    required this.includedBenefits,
    required this.isActive,
    required this.isDeleted,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String name;
  final int durationDays;
  final double price;
  final double? savingsAmount;
  final String includedBenefits;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory MembershipPackageResponse.fromJson(Map<String, dynamic> json) =>
      _$MembershipPackageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipPackageResponseToJson(this);
}
