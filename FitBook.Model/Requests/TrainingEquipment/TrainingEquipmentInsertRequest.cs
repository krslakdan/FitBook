namespace FitBook.Model.Requests.TrainingEquipment;

public class TrainingEquipmentInsertRequest
{
    public string Name { get; set; } = string.Empty;
    public bool IsRequired { get; set; }
    public string? Note { get; set; }
    public int TrainingId { get; set; }
}
