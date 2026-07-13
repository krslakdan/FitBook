namespace FitBook.Model.Requests.TrainingTerms;

/// <summary>
/// Update request for training term logistics only.
/// Status is NOT included — use /cancel or /complete endpoints.
/// </summary>
public class TrainingTermUpdateRequest
{
    public DateTime StartTimeUtc { get; set; }
    public DateTime EndTimeUtc { get; set; }
    public int MaxParticipants { get; set; }
    public bool IsActive { get; set; }
    public int TrainerId { get; set; }
    public int HallId { get; set; }
}
