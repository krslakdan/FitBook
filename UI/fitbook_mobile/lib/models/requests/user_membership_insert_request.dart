import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'user_membership_insert_request.g.dart';

@JsonSerializable()
class UserMembershipInsertRequest implements ApiRequestBody {
  UserMembershipInsertRequest({required this.membershipPackageId});

  final int membershipPackageId;

  factory UserMembershipInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$UserMembershipInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserMembershipInsertRequestToJson(this);
}
