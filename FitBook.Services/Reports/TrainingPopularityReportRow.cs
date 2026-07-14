namespace FitBook.Services.Reports;

internal class TrainingPopularityReportRow
{
    public string TrainingName { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public int ReservationCount { get; set; }
}
