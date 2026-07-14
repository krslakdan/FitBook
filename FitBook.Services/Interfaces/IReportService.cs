using FitBook.Model.Requests.Reports;

namespace FitBook.Services.Interfaces;

public interface IReportService
{
    Task<byte[]> GenerateReservationsReportAsync(ReservationsReportRequest request, CancellationToken cancellationToken = default);
    Task<byte[]> GenerateTrainingPopularityReportAsync(CancellationToken cancellationToken = default);
}
