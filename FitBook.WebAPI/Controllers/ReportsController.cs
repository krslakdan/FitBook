using FitBook.Model.Constants;
using FitBook.Model.Requests.Reports;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = Roles.Admin)]
public class ReportsController : ControllerBase
{
    private readonly IReportService _reportService;

    public ReportsController(IReportService reportService)
    {
        _reportService = reportService;
    }

    [HttpPost("reservations")]
    public async Task<IActionResult> GetReservationsReport(
        [FromBody] ReservationsReportRequest request,
        CancellationToken cancellationToken)
    {
        var pdfBytes = await _reportService.GenerateReservationsReportAsync(request, cancellationToken);
        return File(pdfBytes, "application/pdf", $"reservations-report-{DateTime.UtcNow:yyyyMMdd-HHmmss}.pdf");
    }

    [HttpGet("training-popularity")]
    public async Task<IActionResult> GetTrainingPopularityReport(CancellationToken cancellationToken)
    {
        var pdfBytes = await _reportService.GenerateTrainingPopularityReportAsync(cancellationToken);
        return File(pdfBytes, "application/pdf", $"training-popularity-report-{DateTime.UtcNow:yyyyMMdd-HHmmss}.pdf");
    }
}
