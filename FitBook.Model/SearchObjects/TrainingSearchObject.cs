namespace FitBook.Model.SearchObjects;

public class TrainingSearchObject : BaseSearchObject
{
    public int? TrainingCategoryId { get; set; }
    public int? DifficultyLevelId { get; set; }
    public bool? IsActive { get; set; }
}
