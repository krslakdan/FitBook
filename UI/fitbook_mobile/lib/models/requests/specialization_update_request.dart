import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'specialization_update_request.g.dart';

@JsonSerializable()
class SpecializationUpdateRequest implements ApiRequestBody {
  SpecializationUpdateRequest({
    required this.name,
    required this.isActive,
  });

  final String name;
  final bool isActive;

  factory SpecializationUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$SpecializationUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpecializationUpdateRequestToJson(this);
}
