namespace FitBook.Services.Database.Entities;

public class MembershipPackage : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public int DurationDays { get; set; }
    public decimal Price { get; set; }
    public decimal? SavingsAmount { get; set; }
    public string IncludedBenefits { get; set; } = string.Empty;
    public bool IsActive { get; set; }

    public ICollection<UserMembership> UserMemberships { get; set; } = [];
}
