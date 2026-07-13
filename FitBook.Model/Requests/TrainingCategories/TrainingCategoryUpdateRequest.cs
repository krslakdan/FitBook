namespace FitBook.Model.Requests.TrainingCategories;

public class TrainingCategoryUpdateRequest
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}
