import 'dart:convert';

import '../models/common/page_result.dart';
import '../models/responses/training_recommendation_response.dart';
import 'base_provider.dart';

class RecommendationProvider extends BaseProvider {
  Future<List<TrainingRecommendationResponse>> getRecommendations({int pageSize = 5}) async {
    final response = await apiGet(
      'Recommendations',
      queryParameters: {'page': 1, 'pageSize': pageSize},
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PageResult<TrainingRecommendationResponse>.fromJson(
      decoded,
      (json) => TrainingRecommendationResponse.fromJson(json as Map<String, dynamic>),
    ).items;
  }
}
