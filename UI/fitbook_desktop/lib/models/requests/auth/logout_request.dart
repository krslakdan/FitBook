import 'package:json_annotation/json_annotation.dart';

import '../../common/api_request_body.dart';

part 'logout_request.g.dart';

/// Mirrors `FitBook.Model.Requests.Auth.LogoutRequest`.
@JsonSerializable()
class LogoutRequest implements ApiRequestBody {
  LogoutRequest({required this.refreshToken});

  final String refreshToken;

  factory LogoutRequest.fromJson(Map<String, dynamic> json) => _$LogoutRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LogoutRequestToJson(this);
}
