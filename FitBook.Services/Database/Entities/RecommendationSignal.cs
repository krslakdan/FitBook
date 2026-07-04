using FitBook.Model.Enums;

namespace FitBook.Services.Database.Entities;

public class RecommendationSignal : BaseEntity
{
    public RecommendationSignalType SignalType { get; set; }
    public decimal Weight { get; set; }

    public int UserAccountId { get; set; }
    public UserAccount? UserAccount { get; set; }

    public int TrainingId { get; set; }
    public Training? Training { get; set; }

    public int TrainingCategoryId { get; set; }
    public TrainingCategory? TrainingCategory { get; set; }

    public int? ReservationId { get; set; }
    public Reservation? Reservation { get; set; }
}
