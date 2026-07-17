namespace FitBook.Model.SearchObjects;

public class TrainerSearchObject : BaseSearchObject
{
    public bool? IsActive { get; set; }
    public bool? IsAvailable { get; set; }
    public int? SpecializationId { get; set; }
}
