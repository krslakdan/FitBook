using FitBook.Model.Responses.Recommendations;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class RecommendationsController : ControllerBase
{
    private readonly IRecommendationService _recommendationService;

    public RecommendationsController(IRecommendationService recommendationService)
    {
        _recommendationService = recommendationService;
    }

    [HttpGet]
    public async Task<ActionResult<List<TrainingRecommendationResponse>>> GetRecommendations(
        [FromQuery] int maxResults = 5,
        CancellationToken cancellationToken = default)
    {
        var result = await _recommendationService.GetRecommendationsForCurrentUserAsync(maxResults, cancellationToken);
        return Ok(result);
    }
}
