// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_recommendation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingRecommendationResponse _$TrainingRecommendationResponseFromJson(
  Map<String, dynamic> json,
) => TrainingRecommendationResponse(
  trainingId: (json['trainingId'] as num).toInt(),
  trainingName: json['trainingName'] as String,
  trainingCategoryName: json['trainingCategoryName'] as String,
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  score: (json['score'] as num).toDouble(),
  explanation: json['explanation'] as String,
);

Map<String, dynamic> _$TrainingRecommendationResponseToJson(
  TrainingRecommendationResponse instance,
) => <String, dynamic>{
  'trainingId': instance.trainingId,
  'trainingName': instance.trainingName,
  'trainingCategoryName': instance.trainingCategoryName,
  'durationMinutes': instance.durationMinutes,
  'score': instance.score,
  'explanation': instance.explanation,
};
