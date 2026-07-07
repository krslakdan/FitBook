using FitBook.Model.Enums;

namespace FitBook.Model.Responses.Reservations;

public class ReservationResponse : IEntityResponse
{
    public int Id { get; set; }

    public ReservationStatus Status { get; set; }

    public DateTime ReservedAtUtc { get; set; }
    public DateTime? ConfirmedAtUtc { get; set; }
    public DateTime? CancelledAtUtc { get; set; }
    public DateTime? CompletedAtUtc { get; set; }

    public string? CancellationReason { get; set; }

    public int UserAccountId { get; set; }
    public string UserFirstName { get; set; } = string.Empty;
    public string UserLastName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;
    public int TrainingTermId { get; set; }

    public string TrainingName { get; set; } = string.Empty;
    public DateTime TrainingTermStartTimeUtc { get; set; }
    public DateTime TrainingTermEndTimeUtc { get; set; }

    public int? LastStatusChangedByUserAccountId { get; set; }

    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
