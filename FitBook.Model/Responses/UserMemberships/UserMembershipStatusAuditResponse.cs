using FitBook.Model.Enums;

namespace FitBook.Model.Responses.UserMemberships;

public class UserMembershipStatusAuditResponse
{
    public int Id { get; set; }
    public MembershipStatus PreviousStatus { get; set; }
    public MembershipStatus NewStatus { get; set; }
    public DateTime ChangedAtUtc { get; set; }
    public string? Reason { get; set; }
    public string ChangedByUserFullName { get; set; } = string.Empty;
}
