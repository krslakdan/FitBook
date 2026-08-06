using FitBook.Model.Exceptions;
using FitBook.Services.Interfaces;
using Microsoft.Extensions.Logging;
using Stripe;

namespace FitBook.Services.Payments;

public class StripePaymentService : IStripePaymentService
{
    private readonly ILogger<StripePaymentService> _logger;

    public StripePaymentService(ILogger<StripePaymentService> logger)
    {
        _logger = logger;
    }

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

        try
        {
            return await service.CreateAsync(options, requestOptions, ct);
        }
        catch (StripeException ex)
        {
            _logger.LogError(
                ex,
                "Stripe rejected PaymentIntent creation for amount {Amount} {Currency}. Stripe code: {StripeCode}.",
                amount,
                currency,
                ex.StripeError?.Code);

            throw new BusinessException("Plaćanje trenutno nije moguće pokrenuti za odabrani paket. Kontaktirajte administratora.");
        }
    }

    public async Task<PaymentIntent> GetPaymentIntentAsync(string paymentIntentId, CancellationToken ct)
    {
        var service = new PaymentIntentService();

        try
        {
            return await service.GetAsync(paymentIntentId, null, requestOptions: null, cancellationToken: ct);
        }
        catch (StripeException ex)
        {
            _logger.LogError(
                ex,
                "Stripe could not return PaymentIntent {PaymentIntentId}. Stripe code: {StripeCode}.",
                paymentIntentId,
                ex.StripeError?.Code);

            throw new BusinessException("Trenutno nije moguće provjeriti status plaćanja. Pokušajte ponovo za nekoliko trenutaka.");
        }
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
