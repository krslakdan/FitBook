namespace FitBook.Model.Requests.Equipment;

public class EquipmentInsertRequest
{
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
