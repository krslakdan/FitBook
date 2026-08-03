using FitBook.Model.Enums;

namespace FitBook.Model.Responses.Reservations;

public class ReservationStatusAuditResponse
{
    public int Id { get; set; }
    public ReservationStatus PreviousStatus { get; set; }
    public ReservationStatus NewStatus { get; set; }
    public DateTime ChangedAtUtc { get; set; }
    public string? Reason { get; set; }
    public string ChangedByUserFullName { get; set; } = string.Empty;
}
