using FitBook.Model.Enums;
using FitBook.Model.Responses.Recommendations;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class RecommendationService : IRecommendationService
{
    private const decimal ContentBasedWeight = 0.7m;
    private const decimal PopularityWeight = 0.3m;
    private const decimal ContentDominantThreshold = 0.6m;

    private readonly FitBookDbContext _dbContext;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<RecommendationService> _logger;

    public RecommendationService(
        FitBookDbContext dbContext,
        ICurrentUserService currentUserService,
        ILogger<RecommendationService> logger)
    {
        _dbContext = dbContext;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<List<TrainingRecommendationResponse>> GetRecommendationsForCurrentUserAsync(int maxResults = 5, CancellationToken cancellationToken = default)
    {
        var take = maxResults > 0 ? maxResults : 5;
        var userId = _currentUserService.GetRequiredUserId();

        var categoryAffinities = await _dbContext.RecommendationSignals
            .Where(s => s.UserAccountId == userId)
            .GroupBy(s => s.TrainingCategoryId)
            .Select(g => new { TrainingCategoryId = g.Key, TotalWeight = g.Sum(s => s.Weight) })
            .ToDictionaryAsync(x => x.TrainingCategoryId, x => x.TotalWeight, cancellationToken);

        var popularityCounts = await _dbContext.Reservations
            .Where(r => r.Status == ReservationStatus.Completed)
            .GroupBy(r => r.TrainingTerm!.TrainingId)
            .Select(g => new { TrainingId = g.Key, CompletedCount = g.Count() })
            .ToDictionaryAsync(x => x.TrainingId, x => x.CompletedCount, cancellationToken);

        var alreadyReservedTrainingIds = await _dbContext.Reservations
            .Where(r => r.UserAccountId == userId)
            .Select(r => r.TrainingTerm!.TrainingId)
            .Distinct()
            .ToListAsync(cancellationToken);

        var candidates = await _dbContext.Trainings
            .Where(t => t.IsActive
                        && !alreadyReservedTrainingIds.Contains(t.Id)
                        && t.TrainingTerms.Any(term => term.IsActive
                                                        && term.Status == TrainingTermStatus.Scheduled
                                                        && term.StartTimeUtc > DateTime.UtcNow))
            .Select(t => new
            {
                t.Id,
                t.Name,
                t.TrainingCategoryId,
                t.DurationMinutes,
                CategoryName = t.TrainingCategory!.Name,
            })
            .ToListAsync(cancellationToken);

        var maxCategoryAffinity = categoryAffinities.Count > 0 ? categoryAffinities.Values.Max() : 0m;
        var maxPopularityCount = popularityCounts.Count > 0 ? popularityCounts.Values.Max() : 0;

        var recommendations = new List<TrainingRecommendationResponse>();

        foreach (var candidate in candidates)
        {
            var categoryAffinity = categoryAffinities.GetValueOrDefault(candidate.TrainingCategoryId, 0m);
            var completedCount = popularityCounts.GetValueOrDefault(candidate.Id, 0);

            var contentScore = maxCategoryAffinity > 0 ? categoryAffinity / maxCategoryAffinity : 0m;
            var popularityScore = maxPopularityCount > 0 ? (decimal)completedCount / maxPopularityCount : 0m;

            var contentContribution = contentScore * ContentBasedWeight;
            var totalScore = contentContribution + popularityScore * PopularityWeight;

            var isContentDominant = contentScore > 0
                && totalScore > 0
                && contentContribution / totalScore > ContentDominantThreshold;

            var explanation = isContentDominant
                ? $"Preporučeno jer često rezervišete treninge iz kategorije {candidate.CategoryName}."
                : "Popularan trening među ostalim korisnicima.";

            recommendations.Add(new TrainingRecommendationResponse
            {
                TrainingId = candidate.Id,
                TrainingName = candidate.Name,
                TrainingCategoryName = candidate.CategoryName,
                DurationMinutes = candidate.DurationMinutes,
                Score = totalScore,
                Explanation = explanation,
            });
        }

        var result = recommendations
            .OrderByDescending(r => r.Score)
            .Take(take)
            .ToList();

        _logger.LogInformation(
            "Generated {Count} training recommendations for user {UserId}.",
            result.Count,
            userId);

        return result;
    }
}
