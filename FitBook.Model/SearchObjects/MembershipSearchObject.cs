using FitBook.Model.Enums;

namespace FitBook.Model.SearchObjects;

public class MembershipSearchObject : BaseSearchObject
{
    public int? UserAccountId { get; set; }
    public int? MembershipPackageId { get; set; }
    public MembershipStatus? Status { get; set; }
    public DateTime? ActiveFromUtc { get; set; }
    public DateTime? ActiveToUtc { get; set; }
}
