import '../models/responses/hall_response.dart';
import 'base_crud_provider.dart';

class HallProvider extends BaseCrudProvider<HallResponse> {
  HallProvider() : super('Halls');

  @override
  HallResponse fromJson(Map<String, dynamic> json) => HallResponse.fromJson(json);
}
