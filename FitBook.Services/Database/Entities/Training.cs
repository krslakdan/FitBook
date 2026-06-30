namespace FitBook.Services.Database.Entities;

public class Training
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int DurationMinutes { get; set; }
    public int MaxParticipants { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }

    public int TrainingCategoryId { get; set; }
    public TrainingCategory? TrainingCategory { get; set; }

    public int DifficultyLevelId { get; set; }
    public DifficultyLevel? DifficultyLevel { get; set; }

    public ICollection<TrainingEquipment> EquipmentItems { get; set; } = [];
    public ICollection<TrainingTerm> TrainingTerms { get; set; } = [];
    public ICollection<RecommendationSignal> RecommendationSignals { get; set; } = [];
}
