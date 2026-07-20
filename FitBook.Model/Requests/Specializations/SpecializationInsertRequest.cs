namespace FitBook.Model.Requests.Specializations;

public class SpecializationInsertRequest
{
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
