import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'user_membership_cancel_request.g.dart';

@JsonSerializable()
class UserMembershipCancelRequest implements ApiRequestBody {
  UserMembershipCancelRequest({required this.reason});

  final String reason;

  factory UserMembershipCancelRequest.fromJson(Map<String, dynamic> json) =>
      _$UserMembershipCancelRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserMembershipCancelRequestToJson(this);
}
