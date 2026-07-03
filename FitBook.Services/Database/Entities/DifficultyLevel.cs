namespace FitBook.Services.Database.Entities;

public class DifficultyLevel : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public bool IsActive { get; set; }

    public ICollection<Training> Trainings { get; set; } = [];
}
