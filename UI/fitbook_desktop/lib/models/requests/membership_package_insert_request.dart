import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'membership_package_insert_request.g.dart';

@JsonSerializable()
class MembershipPackageInsertRequest implements ApiRequestBody {
  MembershipPackageInsertRequest({
    required this.name,
    required this.durationDays,
    required this.price,
    this.savingsAmount,
    required this.includedBenefits,
    this.isActive = true,
  });

  final String name;
  final int durationDays;
  final double price;
  final double? savingsAmount;
  final String includedBenefits;
  final bool isActive;

  factory MembershipPackageInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$MembershipPackageInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MembershipPackageInsertRequestToJson(this);
}
