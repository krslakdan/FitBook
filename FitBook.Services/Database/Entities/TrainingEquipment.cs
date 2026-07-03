namespace FitBook.Services.Database.Entities;

public class TrainingEquipment : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public bool IsRequired { get; set; }
    public string? Note { get; set; }

    public int TrainingId { get; set; }
    public Training? Training { get; set; }
}
