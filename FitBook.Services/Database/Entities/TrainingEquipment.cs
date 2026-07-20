namespace FitBook.Services.Database.Entities;

public class TrainingEquipment : BaseEntity
{
    public bool IsRequired { get; set; }
    public string? Note { get; set; }

    public int TrainingId { get; set; }
    public Training? Training { get; set; }

    public int EquipmentId { get; set; }
    public Equipment? Equipment { get; set; }
}
