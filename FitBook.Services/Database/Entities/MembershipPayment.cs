using FitBook.Model.Enums;

namespace FitBook.Services.Database.Entities;

public class MembershipPayment
{
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "BAM";
    public string PaymentProvider { get; set; } = "Stripe";
    public string PaymentIntentId { get; set; } = string.Empty;
    public string? TransactionReference { get; set; }
    public PaymentStatus Status { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? PaidAtUtc { get; set; }
    public DateTime? RefundedAtUtc { get; set; }
    public decimal? RefundAmount { get; set; }

    public int UserMembershipId { get; set; }
    public UserMembership? UserMembership { get; set; }

    public int UserAccountId { get; set; }
    public UserAccount? UserAccount { get; set; }
}
