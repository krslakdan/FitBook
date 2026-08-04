import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'user_membership_change_package_request.g.dart';

@JsonSerializable()
class UserMembershipChangePackageRequest implements ApiRequestBody {
  UserMembershipChangePackageRequest({required this.membershipPackageId});

  final int membershipPackageId;

  factory UserMembershipChangePackageRequest.fromJson(Map<String, dynamic> json) =>
      _$UserMembershipChangePackageRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserMembershipChangePackageRequestToJson(this);
}
