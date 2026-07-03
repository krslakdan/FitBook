namespace FitBook.Services.Database.Entities;

public class Hall : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public int Capacity { get; set; }
    public string? LocationDescription { get; set; }
    public bool IsActive { get; set; }

    public ICollection<TrainingTerm> TrainingTerms { get; set; } = [];
}
