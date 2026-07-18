using FitBook.Model.Constants;
using FitBook.Model.Responses.Dashboard;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = Roles.Admin)]
public class DashboardController : ControllerBase
{
    private readonly IDashboardService _dashboardService;

    public DashboardController(IDashboardService dashboardService)
    {
        _dashboardService = dashboardService;
    }

    [HttpGet("summary")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<DashboardSummaryResponse>> GetSummary(
        [FromQuery] int reservationsDays = 7,
        CancellationToken cancellationToken = default)
    {
        var result = await _dashboardService.GetSummaryAsync(reservationsDays, cancellationToken);
        return Ok(result);
    }
}
