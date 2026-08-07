using FitBook.Model.Enums;
using FitBook.Model.Responses;
using FitBook.Model.Responses.Recommendations;
using FitBook.Model.SearchObjects;
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

    public async Task<PageResult<TrainingRecommendationResponse>> GetRecommendationsForCurrentUserAsync(
        RecommendationSearchObject? search = null,
        CancellationToken cancellationToken = default)
    {
        var searchObject = search ?? new RecommendationSearchObject();
        var pageSize = Math.Min(searchObject.PageSize, RecommendationSearchObject.MaxRecommendationsPageSize);
        var userId = _currentUserService.GetRequiredUserId();

        var categoryAffinities = await _dbContext.RecommendationSignals
            .Where(s => s.UserAccountId == userId)
            .GroupBy(s => s.TrainingCategoryId)
            .Select(g => new { TrainingCategoryId = g.Key, TotalWeight = g.Sum(s => s.Weight) })
            .ToDictionaryAsync(x => x.TrainingCategoryId, x => x.TotalWeight, cancellationToken);

        var popularityCounts = await _dbContext.Reservations
            .Where(r => r.Status != ReservationStatus.Cancelled)
            .GroupBy(r => r.TrainingTerm!.TrainingId)
            .Select(g => new { TrainingId = g.Key, ReservationCount = g.Count() })
            .ToDictionaryAsync(x => x.TrainingId, x => x.ReservationCount, cancellationToken);

        var alreadyReservedTrainingIds = await _dbContext.Reservations
            .Where(r => r.UserAccountId == userId && r.Status != ReservationStatus.Cancelled)
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
            var reservationCount = popularityCounts.GetValueOrDefault(candidate.Id, 0);

            var contentScore = maxCategoryAffinity > 0 ? categoryAffinity / maxCategoryAffinity : 0m;
            var popularityScore = maxPopularityCount > 0 ? (decimal)reservationCount / maxPopularityCount : 0m;

            var contentContribution = contentScore * ContentBasedWeight;
            var totalScore = contentContribution + popularityScore * PopularityWeight;

            var isContentDominant = contentScore > 0
                && totalScore > 0
                && contentContribution / totalScore > ContentDominantThreshold;

            var explanation = isContentDominant
                ? $"Preporučeno jer često birate treninge iz kategorije {candidate.CategoryName}."
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

        var ranked = recommendations
            .OrderByDescending(r => r.Score)
            .ToList();

        var items = ranked
            .Skip((searchObject.Page - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        _logger.LogInformation(
            "Generated {Count} training recommendations for user {UserId}.",
            items.Count,
            userId);

        return new PageResult<TrainingRecommendationResponse>
        {
            Page = searchObject.Page,
            PageSize = pageSize,
            TotalCount = searchObject.IncludeTotalCount == true ? ranked.Count : null,
            TotalPages = searchObject.IncludeTotalCount == true
                ? (ranked.Count == 0 ? 0 : (int)Math.Ceiling(ranked.Count / (double)pageSize))
                : null,
            Items = items
        };
    }
}
