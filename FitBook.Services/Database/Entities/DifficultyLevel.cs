namespace FitBook.Services.Database.Entities;

public class DifficultyLevel
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public bool IsActive { get; set; }

    public ICollection<Training> Trainings { get; set; } = [];
}
