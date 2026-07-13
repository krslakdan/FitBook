namespace FitBook.Model.Requests.Halls;

public class HallInsertRequest
{
    public string Name { get; set; } = string.Empty;
    public int Capacity { get; set; }
    public string? LocationDescription { get; set; }
    public bool IsActive { get; set; }
}
