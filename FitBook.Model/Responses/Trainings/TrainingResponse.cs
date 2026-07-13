namespace FitBook.Model.Responses.Trainings;

public class TrainingResponse : IEntityResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int DurationMinutes { get; set; }
    public int MaxParticipants { get; set; }
    public bool IsActive { get; set; }
    public int TrainingCategoryId { get; set; }
    public string TrainingCategoryName { get; set; } = string.Empty;
    public int DifficultyLevelId { get; set; }
    public string DifficultyLevelName { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
