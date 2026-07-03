using FitBook.Model.Enums;

namespace FitBook.Services.Database.Entities;

public class ReservationStatusAudit : BaseEntity
{
    public ReservationStatus PreviousStatus { get; set; }
    public ReservationStatus NewStatus { get; set; }
    public DateTime ChangedAtUtc { get; set; }
    public string? Reason { get; set; }

    public int ReservationId { get; set; }
    public Reservation? Reservation { get; set; }

    public int ChangedByUserAccountId { get; set; }
    public UserAccount? ChangedByUserAccount { get; set; }
}
