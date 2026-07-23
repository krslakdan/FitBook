using FitBook.Services.Interfaces;
using Stripe;

namespace FitBook.Services.Payments;

public class StripePaymentService : IStripePaymentService
{
    public async Task<PaymentIntent> CreatePaymentIntentAsync(decimal amount, string currency, string idempotencyKey, CancellationToken ct)
    {
        var options = new PaymentIntentCreateOptions
        {
            Amount = ToSmallestCurrencyUnit(amount),
            Currency = currency,
            PaymentMethodTypes = ["card"]
        };

        var requestOptions = new RequestOptions
        {
            IdempotencyKey = idempotencyKey
        };

        var service = new PaymentIntentService();
        return await service.CreateAsync(options, requestOptions, ct);
    }

    public async Task<PaymentIntent> GetPaymentIntentAsync(string paymentIntentId, CancellationToken ct)
    {
        var service = new PaymentIntentService();
        return await service.GetAsync(paymentIntentId, null, requestOptions: null, cancellationToken: ct);
    }

    public async Task<decimal> CreateRefundAsync(string paymentIntentId, CancellationToken ct)
    {
        var options = new RefundCreateOptions
        {
            PaymentIntent = paymentIntentId
        };

        var requestOptions = new RequestOptions
        {
            IdempotencyKey = $"refund_{paymentIntentId}"
        };

        var service = new RefundService();
        var refund = await service.CreateAsync(options, requestOptions, ct);

        return FromSmallestCurrencyUnit(refund.Amount);
    }

    private static long ToSmallestCurrencyUnit(decimal amount) =>
        (long)Math.Round(amount * 100, 0, MidpointRounding.AwayFromZero);

    private static decimal FromSmallestCurrencyUnit(long amount) =>
        amount / 100m;
}
