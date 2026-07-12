namespace FitBook.Model.SearchObjects;

public class MembershipPackageSearchObject : BaseSearchObject
{
    public bool? IsActive { get; set; }

    public bool IncludeDeleted { get; set; }

    public bool IncludeInactive { get; set; }
}
