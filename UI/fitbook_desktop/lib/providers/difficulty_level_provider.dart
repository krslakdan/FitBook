import '../models/responses/difficulty_level_response.dart';
import 'base_crud_provider.dart';

class DifficultyLevelProvider extends BaseCrudProvider<DifficultyLevelResponse> {
  DifficultyLevelProvider() : super('DifficultyLevels');

  @override
  DifficultyLevelResponse fromJson(Map<String, dynamic> json) =>
      DifficultyLevelResponse.fromJson(json);
}
