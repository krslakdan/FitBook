import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_update_request.g.dart';

@JsonSerializable()
class TrainingUpdateRequest implements ApiRequestBody {
  TrainingUpdateRequest({
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

  factory TrainingUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingUpdateRequestToJson(this);
}
