using FitBook.Model.Responses.Dashboard;

namespace FitBook.Services.Interfaces;

public interface IDashboardService
{
    Task<DashboardSummaryResponse> GetSummaryAsync(int reservationsDays, CancellationToken cancellationToken = default);
}
