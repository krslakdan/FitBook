namespace FitBook.Model.Requests.Specializations;

public class SpecializationUpdateRequest
{
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
