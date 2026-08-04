using FitBook.Model.Responses;
using FitBook.Model.Responses.Recommendations;
using FitBook.Model.SearchObjects;
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
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<PageResult<TrainingRecommendationResponse>>> GetRecommendations(
        [FromQuery] RecommendationSearchObject searchObject,
        CancellationToken cancellationToken = default)
    {
        var result = await _recommendationService.GetRecommendationsForCurrentUserAsync(searchObject, cancellationToken);
        return Ok(result);
    }
}
