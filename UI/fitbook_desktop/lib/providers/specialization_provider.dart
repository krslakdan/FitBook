import '../models/responses/specialization_response.dart';
import 'base_crud_provider.dart';

class SpecializationProvider extends BaseCrudProvider<SpecializationResponse> {
  SpecializationProvider() : super('Specializations');

  @override
  SpecializationResponse fromJson(Map<String, dynamic> json) =>
      SpecializationResponse.fromJson(json);
}
