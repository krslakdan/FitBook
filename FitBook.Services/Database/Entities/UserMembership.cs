using FitBook.Model.Enums;

namespace FitBook.Services.Database.Entities;

public class UserMembership : BaseEntity
{
    public DateTime StartDateUtc { get; set; }
    public DateTime EndDateUtc { get; set; }
    public DateTime? NextPaymentDateUtc { get; set; }
    public MembershipStatus Status { get; set; }
    public bool IsActive { get; set; }

    public int UserAccountId { get; set; }
    public UserAccount? UserAccount { get; set; }

    public int MembershipPackageId { get; set; }
    public MembershipPackage? MembershipPackage { get; set; }

    public ICollection<MembershipPayment> Payments { get; set; } = [];
}
