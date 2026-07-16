import '../models/responses/difficulty_level_response.dart';
import 'base_crud_provider.dart';

/// Talks to `DifficultyLevelsController` (`api/difficultylevels`).
class DifficultyLevelProvider extends BaseCrudProvider<DifficultyLevelResponse> {
  DifficultyLevelProvider() : super('DifficultyLevels');

  @override
  DifficultyLevelResponse fromJson(Map<String, dynamic> json) =>
      DifficultyLevelResponse.fromJson(json);
}
