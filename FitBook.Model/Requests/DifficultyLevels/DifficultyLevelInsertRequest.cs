namespace FitBook.Model.Requests.DifficultyLevels;

public class DifficultyLevelInsertRequest
{
    public string Name { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public bool IsActive { get; set; }
}
