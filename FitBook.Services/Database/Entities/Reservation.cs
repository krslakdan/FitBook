using FitBook.Model.Enums;

namespace FitBook.Services.Database.Entities;

public class Reservation : BaseEntity
{
    public ReservationStatus Status { get; set; }
    public DateTime ReservedAtUtc { get; set; }
    public DateTime? ConfirmedAtUtc { get; set; }
    public DateTime? CancelledAtUtc { get; set; }
    public DateTime? CompletedAtUtc { get; set; }
    public DateTime? ReminderSentAtUtc { get; set; }
    public string? CancellationReason { get; set; }

    public int UserAccountId { get; set; }
    public UserAccount? UserAccount { get; set; }

    public int TrainingTermId { get; set; }
    public TrainingTerm? TrainingTerm { get; set; }

    public int? LastStatusChangedByUserAccountId { get; set; }
    public UserAccount? LastStatusChangedByUserAccount { get; set; }

    public ICollection<ReservationStatusAudit> StatusAudits { get; set; } = [];
    public ICollection<RecommendationSignal> RecommendationSignals { get; set; } = [];
}
