using FitBook.Services.Database;
using FitBook.Services.Interfaces.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace FitBook.Services.Auth;

public class TokenVersionService : ITokenVersionService
{
    private static readonly TimeSpan CacheLifetime = TimeSpan.FromMinutes(5);

    private readonly FitBookDbContext _context;
    private readonly IMemoryCache _cache;

    public TokenVersionService(FitBookDbContext context, IMemoryCache cache)
    {
        _context = context;
        _cache = cache;
    }

    public async Task<bool> IsTokenVersionCurrentAsync(int userId, int tokenVersion, CancellationToken cancellationToken = default)
    {
        var cacheKey = BuildCacheKey(userId);

        if (!_cache.TryGetValue<int>(cacheKey, out var currentVersion))
        {
            var storedVersion = await _context.UserAccounts
                .AsNoTracking()
                .Where(x => x.Id == userId && x.IsActive && !x.IsDeleted)
                .Select(x => (int?)x.TokenVersion)
                .FirstOrDefaultAsync(cancellationToken);

            if (storedVersion is null)
            {
                return false;
            }

            currentVersion = storedVersion.Value;
            _cache.Set(cacheKey, currentVersion, CacheLifetime);
        }

        return currentVersion == tokenVersion;
    }

    public async Task InvalidateIssuedTokensAsync(int userId, CancellationToken cancellationToken = default)
    {
        var user = await _context.UserAccounts.FirstOrDefaultAsync(x => x.Id == userId, cancellationToken);

        if (user is null)
        {
            return;
        }

        user.TokenVersion++;
        user.UpdatedAtUtc = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        _cache.Remove(BuildCacheKey(userId));
    }

    private static string BuildCacheKey(int userId) => $"token-version-{userId}";
}
