import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'membership_package_update_request.g.dart';

/// Mirrors `FitBook.Model.Requests.MembershipPackageUpdateRequest`.
@JsonSerializable()
class MembershipPackageUpdateRequest implements ApiRequestBody {
  MembershipPackageUpdateRequest({
    required this.name,
    required this.durationDays,
    required this.price,
    this.savingsAmount,
    required this.includedBenefits,
    this.isActive = false,
  });

  final String name;
  final int durationDays;
  final double price;
  final double? savingsAmount;
  final String includedBenefits;
  final bool isActive;

  factory MembershipPackageUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$MembershipPackageUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MembershipPackageUpdateRequestToJson(this);
}
