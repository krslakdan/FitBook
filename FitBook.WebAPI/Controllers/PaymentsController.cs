using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stripe;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PaymentsController : ControllerBase
{
    private readonly IStripePaymentService _stripePaymentService;
    private readonly IUserMembershipService _userMembershipService;
    private readonly IConfiguration _configuration;
    private readonly ILogger<PaymentsController> _logger;

    public PaymentsController(
        IStripePaymentService stripePaymentService,
        IUserMembershipService userMembershipService,
        IConfiguration configuration,
        ILogger<PaymentsController> logger)
    {
        _stripePaymentService = stripePaymentService;
        _userMembershipService = userMembershipService;
        _configuration = configuration;
        _logger = logger;
    }

    [HttpPost("webhook/stripe")]
    [AllowAnonymous] 
    public async Task<IActionResult> StripeWebhook(CancellationToken cancellationToken)
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        var signatureHeader = Request.Headers["Stripe-Signature"];
        var webhookSecret = _configuration["Stripe:WebhookSecret"];

        if (string.IsNullOrEmpty(webhookSecret))
        {
            _logger.LogError("Stripe WebhookSecret is not configured.");
            return StatusCode(500, "Stripe configuration error.");
        }

        try
        {
            var stripeEvent = _stripePaymentService.ConstructWebhookEvent(json, signatureHeader!, webhookSecret);

            if (stripeEvent.Type == "payment_intent.succeeded")
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                await _userMembershipService.MarkPaymentSuccessfulAsync(paymentIntent!.Id, cancellationToken);
            }
            else if (stripeEvent.Type == "payment_intent.payment_failed")
            {
                var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                await _userMembershipService.MarkPaymentFailedAsync(paymentIntent!.Id, cancellationToken);
            }

            return Ok();
        }
        catch (StripeException e)
        {
            _logger.LogWarning("Stripe Webhook Signature Verification Failed: {Error}", e.Message);
            return BadRequest("Webhook signature verification failed.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error handling Stripe webhook.");
            return StatusCode(500);
        }
    }
}