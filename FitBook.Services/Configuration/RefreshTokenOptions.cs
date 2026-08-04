namespace FitBook.Services.Configuration;

public sealed class RefreshTokenOptions
{
    public const string SectionName = "RefreshToken";

    public int ExpirationDays { get; set; } = 7;
}
