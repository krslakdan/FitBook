using FitBook.Model.Enums;

namespace FitBook.Services.Reports;

internal class ReservationReportRow
{
    public string UserFullName { get; set; } = string.Empty;
    public string TrainingName { get; set; } = string.Empty;
    public DateTime TrainingTermStartUtc { get; set; }
    public ReservationStatus Status { get; set; }
    public DateTime ReservedAtUtc { get; set; }
}
