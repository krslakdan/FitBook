import 'package:json_annotation/json_annotation.dart';

part 'training_recommendation_response.g.dart';

@JsonSerializable()
class TrainingRecommendationResponse {
  TrainingRecommendationResponse({
    required this.trainingId,
    required this.trainingName,
    required this.trainingCategoryName,
    required this.durationMinutes,
    required this.score,
    required this.explanation,
  });

  final int trainingId;
  final String trainingName;
  final String trainingCategoryName;
  final int durationMinutes;
  final double score;
  final String explanation;

  factory TrainingRecommendationResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainingRecommendationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingRecommendationResponseToJson(this);
}
