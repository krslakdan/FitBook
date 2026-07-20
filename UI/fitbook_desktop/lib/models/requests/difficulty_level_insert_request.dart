import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'difficulty_level_insert_request.g.dart';

@JsonSerializable()
class DifficultyLevelInsertRequest implements ApiRequestBody {
  DifficultyLevelInsertRequest({
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  final String name;
  final int sortOrder;
  final bool isActive;

  factory DifficultyLevelInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$DifficultyLevelInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DifficultyLevelInsertRequestToJson(this);
}
