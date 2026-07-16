import 'package:json_annotation/json_annotation.dart';

part 'training_response.g.dart';

/// Mirrors `FitBook.Model.Responses.TrainingResponse`.
@JsonSerializable()
class TrainingResponse {
  TrainingResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.maxParticipants,
    required this.isActive,
    required this.trainingCategoryId,
    required this.trainingCategoryName,
    required this.difficultyLevelId,
    required this.difficultyLevelName,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String name;
  final String description;
  final int durationMinutes;
  final int maxParticipants;
  final bool isActive;
  final int trainingCategoryId;
  final String trainingCategoryName;
  final int difficultyLevelId;
  final String difficultyLevelName;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory TrainingResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingResponseToJson(this);
}
