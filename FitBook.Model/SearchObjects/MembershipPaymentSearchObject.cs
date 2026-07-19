using FitBook.Model.Enums;

namespace FitBook.Model.SearchObjects;

public class MembershipPaymentSearchObject : BaseSearchObject
{
    public int? UserAccountId { get; set; }
    public int? UserMembershipId { get; set; }
    public PaymentStatus? Status { get; set; }
}
