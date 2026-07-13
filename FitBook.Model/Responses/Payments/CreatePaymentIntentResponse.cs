namespace FitBook.Model.Responses.Payments;

public class CreatePaymentIntentResponse
{
    public string ClientSecret { get; set; } = string.Empty;
    public int PaymentId { get; set; }
}
