using FitBook.Model.Enums;

namespace FitBook.Services.Database.Entities;

public class TrainingTerm
{
    public int Id { get; set; }
    public DateTime StartTimeUtc { get; set; }
    public DateTime EndTimeUtc { get; set; }
    public int MaxParticipants { get; set; }
    public TrainingTermStatus Status { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }

    public int TrainingId { get; set; }
    public Training? Training { get; set; }

    public int TrainerId { get; set; }
    public Trainer? Trainer { get; set; }

    public int HallId { get; set; }
    public Hall? Hall { get; set; }

    public ICollection<Reservation> Reservations { get; set; } = [];
}
