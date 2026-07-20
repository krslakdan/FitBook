namespace FitBook.Services.Database.Entities;

public class Equipment : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }

    public ICollection<TrainingEquipment> TrainingEquipmentItems { get; set; } = [];
}
