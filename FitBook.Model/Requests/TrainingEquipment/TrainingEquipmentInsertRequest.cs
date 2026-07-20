namespace FitBook.Model.Requests.TrainingEquipment;

public class TrainingEquipmentInsertRequest
{
    public bool IsRequired { get; set; }
    public string? Note { get; set; }
    public int TrainingId { get; set; }
    public int EquipmentId { get; set; }
}
