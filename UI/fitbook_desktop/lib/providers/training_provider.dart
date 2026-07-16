import '../models/responses/training_response.dart';
import 'base_crud_provider.dart';

/// Talks to `TrainingsController` (`api/trainings`).
class TrainingProvider extends BaseCrudProvider<TrainingResponse> {
  TrainingProvider() : super('Trainings');

  @override
  TrainingResponse fromJson(Map<String, dynamic> json) => TrainingResponse.fromJson(json);
}
