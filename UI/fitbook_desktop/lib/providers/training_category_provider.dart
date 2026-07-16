import '../models/responses/training_category_response.dart';
import 'base_crud_provider.dart';

/// Talks to `TrainingCategoriesController` (`api/trainingcategories`).
class TrainingCategoryProvider extends BaseCrudProvider<TrainingCategoryResponse> {
  TrainingCategoryProvider() : super('TrainingCategories');

  @override
  TrainingCategoryResponse fromJson(Map<String, dynamic> json) =>
      TrainingCategoryResponse.fromJson(json);
}
