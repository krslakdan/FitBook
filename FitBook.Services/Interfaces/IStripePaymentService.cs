using Stripe;

namespace FitBook.Services.Interfaces;

public interface IStripePaymentService
{
    Task<PaymentIntent> CreatePaymentIntentAsync(decimal amount, string currency, string idempotencyKey, CancellationToken ct);
    Task<PaymentIntent> GetPaymentIntentAsync(string paymentIntentId, CancellationToken ct);
    Task<decimal> CreateRefundAsync(string paymentIntentId, CancellationToken ct);
}
