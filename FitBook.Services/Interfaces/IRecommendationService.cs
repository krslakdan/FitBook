using FitBook.Model.Responses.Recommendations;

namespace FitBook.Services.Interfaces;

public interface IRecommendationService
{
    Task<List<TrainingRecommendationResponse>> GetRecommendationsForCurrentUserAsync(int maxResults = 5, CancellationToken cancellationToken = default);
}
