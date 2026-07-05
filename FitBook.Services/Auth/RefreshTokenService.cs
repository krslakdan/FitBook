using System.Security.Cryptography;
using FitBook.Model.Exceptions;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces.Auth;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace FitBook.Services.Auth;

public class RefreshTokenService : IRefreshTokenService
{
    private readonly FitBookDbContext _context;
    private readonly IConfiguration _configuration;

    public RefreshTokenService(FitBookDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<RefreshToken> GenerateRefreshTokenAsync(int userId, CancellationToken cancellationToken = default)
    {
        var token = GenerateSecureToken();
        var daysToLive = int.Parse(_configuration["RefreshToken:ExpirationDays"] ?? "7");
        
        var refreshToken = new RefreshToken
        {
            Token = token,
            UserId = userId,
            ExpiresAtUtc = DateTime.UtcNow.AddDays(daysToLive),
            CreatedAtUtc = DateTime.UtcNow
        };

        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync(cancellationToken);

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
            await _context.SaveChangesAsync(cancellationToken);
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

        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task<RefreshToken> RotateRefreshTokenAsync(string existingToken, CancellationToken cancellationToken = default)
    {
        var oldToken = await _context.RefreshTokens.SingleOrDefaultAsync(x => x.Token == existingToken, cancellationToken);
        if (oldToken == null) throw new NotFoundException("Refresh token not found");

        var newToken = GenerateSecureToken();
        var daysToLive = int.Parse(_configuration["RefreshToken:ExpirationDays"] ?? "7");
        
        oldToken.RevokedAtUtc = DateTime.UtcNow;
        oldToken.ReplacedByToken = newToken;

        var refreshToken = new RefreshToken
        {
            Token = newToken,
            UserId = oldToken.UserId,
            ExpiresAtUtc = DateTime.UtcNow.AddDays(daysToLive),
            CreatedAtUtc = DateTime.UtcNow
        };

        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync(cancellationToken);

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
