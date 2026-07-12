namespace FitBook.Model.Requests.MembershipPackages;

public class MembershipPackageUpdateRequest
{
    public string Name { get; set; } = string.Empty;
    public int DurationDays { get; set; }
    public decimal Price { get; set; }
    public decimal? SavingsAmount { get; set; }
    public string IncludedBenefits { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
