namespace FitBook.Services.Database.Entities;

public class TrainingCategory
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }

    public ICollection<Training> Trainings { get; set; } = [];
    public ICollection<RecommendationSignal> RecommendationSignals { get; set; } = [];
}
