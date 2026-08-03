namespace FitBook.Model.Requests.Reports;

public class ReservationsReportRequest
{
    public DateOnly FromDate { get; set; }
    public DateOnly ToDate { get; set; }
}
