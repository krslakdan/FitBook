import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'difficulty_level_update_request.g.dart';

/// Mirrors `FitBook.Model.Requests.DifficultyLevelUpdateRequest`.
@JsonSerializable()
class DifficultyLevelUpdateRequest implements ApiRequestBody {
  DifficultyLevelUpdateRequest({
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  final String name;
  final int sortOrder;
  final bool isActive;

  factory DifficultyLevelUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$DifficultyLevelUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DifficultyLevelUpdateRequestToJson(this);
}
