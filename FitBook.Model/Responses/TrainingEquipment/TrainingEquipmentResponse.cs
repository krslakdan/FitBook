namespace FitBook.Model.Responses.TrainingEquipment;

public class TrainingEquipmentResponse : IEntityResponse
{
    public int Id { get; set; }
    public bool IsRequired { get; set; }
    public string? Note { get; set; }
    public int TrainingId { get; set; }
    public int EquipmentId { get; set; }
    public string EquipmentName { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
