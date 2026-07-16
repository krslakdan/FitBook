import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_insert_request.g.dart';

@JsonSerializable()
class TrainingInsertRequest implements ApiRequestBody {
  TrainingInsertRequest({
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.maxParticipants,
    required this.isActive,
    required this.trainingCategoryId,
    required this.difficultyLevelId,
  });

  final String name;
  final String description;
  final int durationMinutes;
  final int maxParticipants;
  final bool isActive;
  final int trainingCategoryId;
  final int difficultyLevelId;

  factory TrainingInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingInsertRequestToJson(this);
}
