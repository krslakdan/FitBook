namespace FitBook.Model.Responses.TrainingEquipment;

public class TrainingEquipmentResponse : IEntityResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsRequired { get; set; }
    public string? Note { get; set; }
    public int TrainingId { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
