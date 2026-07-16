import '../models/responses/training_equipment_response.dart';
import 'base_crud_provider.dart';

/// Talks to `TrainingEquipmentController` (`api/trainingequipment` — note:
/// singular, matching the backend controller name exactly).
class TrainingEquipmentProvider extends BaseCrudProvider<TrainingEquipmentResponse> {
  TrainingEquipmentProvider() : super('TrainingEquipment');

  @override
  TrainingEquipmentResponse fromJson(Map<String, dynamic> json) =>
      TrainingEquipmentResponse.fromJson(json);
}
