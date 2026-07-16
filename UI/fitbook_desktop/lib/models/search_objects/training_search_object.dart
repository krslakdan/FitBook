import '../common/base_search_object.dart';

/// Mirrors `FitBook.Model.SearchObjects.TrainingSearchObject`.
class TrainingSearchObject extends BaseSearchObject {
  const TrainingSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.trainingCategoryId,
    this.difficultyLevelId,
    this.isActive,
  });

  final int? trainingCategoryId;
  final int? difficultyLevelId;
  final bool? isActive;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (trainingCategoryId != null) params['trainingCategoryId'] = trainingCategoryId;
    if (difficultyLevelId != null) params['difficultyLevelId'] = difficultyLevelId;
    if (isActive != null) params['isActive'] = isActive;
    return params;
  }
}
