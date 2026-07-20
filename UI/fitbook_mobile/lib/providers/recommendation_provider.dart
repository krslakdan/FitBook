import 'dart:convert';

import '../models/responses/training_recommendation_response.dart';
import 'base_provider.dart';

class RecommendationProvider extends BaseProvider {
  Future<List<TrainingRecommendationResponse>> getRecommendations({int maxResults = 5}) async {
    final response = await apiGet('Recommendations', queryParameters: {'maxResults': maxResults});
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => TrainingRecommendationResponse.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
