namespace FitBook.Services.Validators;

public static class ValidationPatterns
{
    public const string Email = @"^[^@\s]+@[^@\s]+\.[A-Za-z]{2,}$";

    public const string Phone = @"^(?=(?:.*\d){6,})\+?[0-9\s\-()]{6,20}$";
}
