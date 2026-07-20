import '../models/responses/equipment_response.dart';
import 'base_crud_provider.dart';

class EquipmentProvider extends BaseCrudProvider<EquipmentResponse> {
  EquipmentProvider() : super('Equipment');

  @override
  EquipmentResponse fromJson(Map<String, dynamic> json) =>
      EquipmentResponse.fromJson(json);
}
