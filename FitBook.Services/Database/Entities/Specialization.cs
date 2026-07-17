namespace FitBook.Services.Database.Entities;

public class Specialization : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }

    public ICollection<Trainer> Trainers { get; set; } = [];
}
