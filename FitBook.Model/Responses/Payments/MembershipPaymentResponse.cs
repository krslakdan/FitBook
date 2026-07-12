using FitBook.Model.Enums;

namespace FitBook.Model.Responses.Payments;

public class MembershipPaymentResponse : IEntityResponse
{
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = string.Empty;
    public string PaymentProvider { get; set; } = string.Empty;
    public PaymentStatus Status { get; set; }
    public DateTime? PaidAtUtc { get; set; }
    public DateTime? RefundedAtUtc { get; set; }
    public decimal? RefundAmount { get; set; }
    public int UserMembershipId { get; set; }
    public int UserAccountId { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
