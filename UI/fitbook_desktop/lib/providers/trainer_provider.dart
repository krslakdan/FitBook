import '../models/responses/trainer_response.dart';
import 'base_crud_provider.dart';

/// Talks to `TrainersController` (`api/trainers`).
class TrainerProvider extends BaseCrudProvider<TrainerResponse> {
  TrainerProvider() : super('Trainers');

  @override
  TrainerResponse fromJson(Map<String, dynamic> json) => TrainerResponse.fromJson(json);
}
