using FitBook.Model.Responses;
using FitBook.Model.Responses.Recommendations;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IRecommendationService
{
    Task<PageResult<TrainingRecommendationResponse>> GetRecommendationsForCurrentUserAsync(
        RecommendationSearchObject? search = null,
        CancellationToken cancellationToken = default);
}
