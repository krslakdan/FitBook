namespace FitBook.Model.Requests.Trainers;

public class TrainerUpdateRequest
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public int SpecializationId { get; set; }
    public string? Biography { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsAvailable { get; set; }
    public bool IsActive { get; set; }
}
