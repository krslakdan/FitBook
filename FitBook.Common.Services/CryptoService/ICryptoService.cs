namespace FitBook.Common.Services.CryptoService;

public interface ICryptoService
{
    string HashPassword(string password);

    bool VerifyPassword(string password, string passwordHash);
}
