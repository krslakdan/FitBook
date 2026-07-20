import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'specialization_insert_request.g.dart';

@JsonSerializable()
class SpecializationInsertRequest implements ApiRequestBody {
  SpecializationInsertRequest({
    required this.name,
    required this.isActive,
  });

  final String name;
  final bool isActive;

  factory SpecializationInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$SpecializationInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpecializationInsertRequestToJson(this);
}
