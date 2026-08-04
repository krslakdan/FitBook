namespace FitBook.Services.Configuration;

public sealed class JwtOptions
{
    public const string SectionName = "JwtToken";

    public string SecretKey { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int ExpirationMinutes { get; set; } = 15;
}
