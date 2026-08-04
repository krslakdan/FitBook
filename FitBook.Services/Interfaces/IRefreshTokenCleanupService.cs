namespace FitBook.Services.Interfaces;

public interface IRefreshTokenCleanupService
{
    Task<int> RemoveStaleRefreshTokensAsync(CancellationToken cancellationToken = default);
}
