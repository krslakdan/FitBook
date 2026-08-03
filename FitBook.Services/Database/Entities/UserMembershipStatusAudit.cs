using FitBook.Model.Enums;

namespace FitBook.Services.Database.Entities;

public class UserMembershipStatusAudit : BaseEntity
{
    public MembershipStatus PreviousStatus { get; set; }
    public MembershipStatus NewStatus { get; set; }
    public DateTime ChangedAtUtc { get; set; }
    public string? Reason { get; set; }

    public int UserMembershipId { get; set; }
    public UserMembership? UserMembership { get; set; }

    public int? ChangedByUserAccountId { get; set; }
    public UserAccount? ChangedByUserAccount { get; set; }
}
