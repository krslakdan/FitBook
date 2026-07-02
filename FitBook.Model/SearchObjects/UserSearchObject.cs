namespace FitBook.Model.SearchObjects;

public class UserSearchObject : BaseSearchObject
{
    public string? Role { get; set; }
    public bool? IsActive { get; set; }
    public bool IncludeDeleted { get; set; }
}
