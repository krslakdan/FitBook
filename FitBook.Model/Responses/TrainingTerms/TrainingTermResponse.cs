using FitBook.Model.Enums;

namespace FitBook.Model.Responses.TrainingTerms;

public class TrainingTermResponse : IEntityResponse
{
    public int Id { get; set; }
    public DateTime StartTimeUtc { get; set; }
    public DateTime EndTimeUtc { get; set; }
    public int MaxParticipants { get; set; }
    public int ReservedCount { get; set; }
    public TrainingTermStatus Status { get; set; }
    public bool IsActive { get; set; }
    public int TrainingId { get; set; }
    public string TrainingName { get; set; } = string.Empty;
    public int TrainerId { get; set; }
    public string TrainerFirstName { get; set; } = string.Empty;
    public string TrainerLastName { get; set; } = string.Empty;
    public int HallId { get; set; }
    public string HallName { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
