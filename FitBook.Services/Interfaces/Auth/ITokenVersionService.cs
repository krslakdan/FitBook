namespace FitBook.Services.Interfaces.Auth;

public interface ITokenVersionService
{
    Task<bool> IsTokenVersionCurrentAsync(int userId, int tokenVersion, CancellationToken cancellationToken = default);

    Task InvalidateIssuedTokensAsync(int userId, CancellationToken cancellationToken = default);
}
