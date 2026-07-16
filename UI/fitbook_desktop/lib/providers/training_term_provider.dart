import 'dart:convert';

import '../models/requests/training_term_cancel_request.dart';
import '../models/responses/training_term_response.dart';
import 'base_crud_provider.dart';

/// Talks to `TrainingTermsController` (`api/trainingterms`).
class TrainingTermProvider extends BaseCrudProvider<TrainingTermResponse> {
  TrainingTermProvider() : super('TrainingTerms');

  @override
  TrainingTermResponse fromJson(Map<String, dynamic> json) => TrainingTermResponse.fromJson(json);

  Future<TrainingTermResponse> cancel(int id, TrainingTermCancelRequest request) async {
    final response = await apiPost('$endpoint/$id/cancel', body: request);
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<TrainingTermResponse> complete(int id) async {
    final response = await apiPost('$endpoint/$id/complete');
    return fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
