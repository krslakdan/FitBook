using System.Security.Cryptography;
using FitBook.Model.Exceptions;
using FitBook.Services.Configuration;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace FitBook.Services.Auth;

public class RefreshTokenService : IRefreshTokenService
{
    private readonly FitBookDbContext _context;
    private readonly RefreshTokenOptions _options;

    public RefreshTokenService(FitBookDbContext context, IOptions<RefreshTokenOptions> options)
    {
        _context = context;
        _options = options.Value;
    }

    public RefreshToken CreateRefreshToken(int userId)
    {
        var refreshToken = new RefreshToken
        {
            Token = GenerateSecureToken(),
            UserId = userId,
            ExpiresAtUtc = DateTime.UtcNow.AddDays(_options.ExpirationDays),
            CreatedAtUtc = DateTime.UtcNow
        };

        _context.RefreshTokens.Add(refreshToken);

        return refreshToken;
    }

    public async Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default)
    {
        return await _context.RefreshTokens
            .SingleOrDefaultAsync(x => x.Token == token, cancellationToken);
    }

    public async Task RevokeRefreshTokenAsync(string token, CancellationToken cancellationToken = default)
    {
        var refreshToken = await _context.RefreshTokens.SingleOrDefaultAsync(x => x.Token == token, cancellationToken);

        if (refreshToken != null)
        {
            refreshToken.RevokedAtUtc = DateTime.UtcNow;
        }
    }

    public async Task RevokeAllUserRefreshTokensAsync(int userId, CancellationToken cancellationToken = default)
    {
        var tokens = await _context.RefreshTokens
            .Where(x => x.UserId == userId && x.RevokedAtUtc == null && x.ExpiresAtUtc > DateTime.UtcNow)
            .ToListAsync(cancellationToken);

        foreach (var token in tokens)
        {
            token.RevokedAtUtc = DateTime.UtcNow;
        }
    }

    public async Task<RefreshToken> RotateRefreshTokenAsync(string existingToken, CancellationToken cancellationToken = default)
    {
        var oldToken = await _context.RefreshTokens.SingleOrDefaultAsync(x => x.Token == existingToken, cancellationToken);
        if (oldToken == null) throw new NotFoundException("Refresh token nije pronađen.");

        var refreshToken = CreateRefreshToken(oldToken.UserId);

        oldToken.RevokedAtUtc = DateTime.UtcNow;
        oldToken.ReplacedByToken = refreshToken.Token;

        return refreshToken;
    }

    private string GenerateSecureToken()
    {
        var randomBytes = new byte[64];
        using (var rng = RandomNumberGenerator.Create())
        {
            rng.GetBytes(randomBytes);
        }
        return Convert.ToBase64String(randomBytes);
    }
}
