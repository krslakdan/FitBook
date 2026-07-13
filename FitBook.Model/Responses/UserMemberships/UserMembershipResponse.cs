using FitBook.Model.Enums;

namespace FitBook.Model.Responses.UserMemberships;

public class UserMembershipResponse : IEntityResponse
{
    public int Id { get; set; }

    public MembershipStatus Status { get; set; }

    public DateTime StartDateUtc { get; set; }
    public DateTime EndDateUtc { get; set; }
    public DateTime? NextPaymentDateUtc { get; set; }

    public bool IsActive { get; set; }

    public bool IsPaid { get; set; }

    public int UserAccountId { get; set; }
    public string UserFirstName { get; set; } = string.Empty;
    public string UserLastName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;

    public int MembershipPackageId { get; set; }
    public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }
    public int PackageDurationDays { get; set; }

    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
