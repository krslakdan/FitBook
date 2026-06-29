namespace FitBook.Services.Database.Entities;

public class Trainer
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Specialization { get; set; } = string.Empty;
    public string? Biography { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsAvailable { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }

    public int UserAccountId { get; set; }
    public UserAccount UserAccount { get; set; } = null!;

    public ICollection<TrainingTerm> TrainingTerms { get; set; } = [];
}
