using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class RefreshTokenCleanupService : IRefreshTokenCleanupService
{
    private static readonly TimeSpan RevokedTokenRetention = TimeSpan.FromDays(7);

    private readonly FitBookDbContext _dbContext;
    private readonly ILogger<RefreshTokenCleanupService> _logger;

    public RefreshTokenCleanupService(FitBookDbContext dbContext, ILogger<RefreshTokenCleanupService> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task<int> RemoveStaleRefreshTokensAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var revokedCutoffUtc = now - RevokedTokenRetention;

        var removedCount = await _dbContext.RefreshTokens
            .Where(x => x.ExpiresAtUtc <= now
                        || (x.RevokedAtUtc != null && x.RevokedAtUtc <= revokedCutoffUtc))
            .ExecuteDeleteAsync(cancellationToken);

        if (removedCount > 0)
        {
            _logger.LogInformation("Removed {Count} expired or long-revoked refresh token(s).", removedCount);
        }

        return removedCount;
    }
}
