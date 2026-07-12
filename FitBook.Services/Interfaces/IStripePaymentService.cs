using Stripe;

namespace FitBook.Services.Interfaces;

public interface IStripePaymentService
{
    Task<PaymentIntent> CreatePaymentIntentAsync(decimal amount, string currency, string idempotencyKey, CancellationToken ct);
    Task<PaymentIntent> GetPaymentIntentAsync(string paymentIntentId, CancellationToken ct);
    Task<Refund> CreateRefundAsync(string paymentIntentId, decimal amount, CancellationToken ct);
    Event ConstructWebhookEvent(string payload, string signatureHeader, string secret);
}
