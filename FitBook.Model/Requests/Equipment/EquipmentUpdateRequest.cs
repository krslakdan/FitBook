namespace FitBook.Model.Requests.Equipment;

public class EquipmentUpdateRequest
{
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
