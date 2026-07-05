using FitBook.Services.Database.Entities;

namespace FitBook.Services.Interfaces.Auth;

public interface IRefreshTokenService
{
    Task<RefreshToken> GenerateRefreshTokenAsync(int userId, CancellationToken cancellationToken = default);
    Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default);
    Task RevokeRefreshTokenAsync(string token, CancellationToken cancellationToken = default);
    Task RevokeAllUserRefreshTokensAsync(int userId, CancellationToken cancellationToken = default);
    Task<RefreshToken> RotateRefreshTokenAsync(string existingToken, CancellationToken cancellationToken = default);
}
