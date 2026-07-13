namespace FitBook.Model.Requests.Trainings;

public class TrainingInsertRequest
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int DurationMinutes { get; set; }
    public int MaxParticipants { get; set; }
    public bool IsActive { get; set; }
    public int TrainingCategoryId { get; set; }
    public int DifficultyLevelId { get; set; }
}
