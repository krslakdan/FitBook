namespace FitBook.Model.Requests.TrainingTerms;

public class TrainingTermInsertRequest
{
    public DateTime StartTimeUtc { get; set; }
    public DateTime EndTimeUtc { get; set; }
    public int MaxParticipants { get; set; }
    public bool IsActive { get; set; }
    public int TrainingId { get; set; }
    public int TrainerId { get; set; }
    public int HallId { get; set; }
}
