using FitBook.Common.Services.CryptoService;
using FitBook.Model.Constants;
using FitBook.Model.Exceptions;
using FitBook.Model.Messages;
using FitBook.Model.Requests.Auth;
using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.Auth;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using FitBook.Services.Interfaces.Auth;
using FitBook.Services.Database.Entities;
using FitBook.Services.Messaging;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Globalization;
using System.Security.Cryptography;

namespace FitBook.Services.Auth;

public class AuthService : IAuthService
{
    private static readonly TimeSpan PasswordResetCodeLifetime = TimeSpan.FromMinutes(15);

    private const int MaxPasswordResetAttempts = 5;

    private const string InvalidResetCodeMessage =
        "Nevažeći ili istekao kod za reset lozinke. Zatražite novi kod i pokušajte ponovo.";

    private readonly FitBookDbContext _context;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IRefreshTokenService _refreshTokenService;
    private readonly ITokenVersionService _tokenVersionService;
    private readonly IUserAccountService _userAccountService;
    private readonly ICryptoService _cryptoService;
    private readonly IEmailNotificationPublisher _emailNotificationPublisher;
    private readonly IValidator<ForgotPasswordRequest> _forgotPasswordValidator;
    private readonly IValidator<ResetPasswordRequest> _resetPasswordValidator;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        FitBookDbContext context,
        IJwtTokenService jwtTokenService,
        IRefreshTokenService refreshTokenService,
        ITokenVersionService tokenVersionService,
        IUserAccountService userAccountService,
        ICryptoService cryptoService,
        IEmailNotificationPublisher emailNotificationPublisher,
        IValidator<ForgotPasswordRequest> forgotPasswordValidator,
        IValidator<ResetPasswordRequest> resetPasswordValidator,
        ILogger<AuthService> logger)
    {
        _context = context;
        _jwtTokenService = jwtTokenService;
        _refreshTokenService = refreshTokenService;
        _tokenVersionService = tokenVersionService;
        _userAccountService = userAccountService;
        _cryptoService = cryptoService;
        _emailNotificationPublisher = emailNotificationPublisher;
        _forgotPasswordValidator = forgotPasswordValidator;
        _resetPasswordValidator = resetPasswordValidator;
        _logger = logger;
    }

    public async Task<UserLoginResponse> LoginAsync(UserLoginRequest request, CancellationToken cancellationToken = default)
    {
        var user = await _context.UserAccounts
            .SingleOrDefaultAsync(x => x.Username.ToLower() == request.Username.Trim().ToLower() && !x.IsDeleted, cancellationToken);

        if (user == null || !_cryptoService.VerifyPassword(request.Password, user.PasswordHash))
        {
            _logger.LogWarning("Failed login attempt for username: {Username}", request.Username);
            throw new BusinessException("Neispravni podaci za prijavu.");
        }

        if (!user!.IsActive)
        {
            _logger.LogWarning("Login attempt for inactive user: {Username}", request.Username);
            throw new BusinessException("Korisnički nalog nije aktivan.");
        }

        var accessToken = _jwtTokenService.GenerateAccessToken(user);
        var refreshToken = _refreshTokenService.CreateRefreshToken(user.Id);
        await _context.SaveChangesAsync(cancellationToken);

        return new UserLoginResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken.Token,
            RefreshTokenExpiresAtUtc = refreshToken.ExpiresAtUtc
        };
    }

    public async Task RegisterAsync(UserRegisterRequest request, CancellationToken cancellationToken = default)
    {
        var insertRequest = new UserAccountInsertRequest
        {
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Email = request.Email.Trim(),
            PhoneNumber = request.PhoneNumber.Trim(),
            Username = request.Username.Trim(),
            Password = request.Password.Trim(),
            Role = Roles.User,
            IsActive = true
        };

        await _userAccountService.CreateUserAsync(insertRequest, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
        {
            ToEmail = insertRequest.Email,
            ToName = $"{insertRequest.FirstName} {insertRequest.LastName}",
            Subject = "Dobrodošli u FitBook",
            Body = $"Poštovani {insertRequest.FirstName}, Vaš FitBook nalog je uspješno kreiran. Dobrodošli!",
        }, cancellationToken);
    }

    public async Task<RefreshTokenResponse> RefreshTokenAsync(RefreshTokenRequest request, CancellationToken cancellationToken = default)
    {
        var refreshToken = await _refreshTokenService.GetByTokenAsync(request.RefreshToken.Trim(), cancellationToken);

        if (refreshToken == null)
        {
            throw new BusinessException("Nevažeći refresh token.");
        }

        if (refreshToken.RevokedAtUtc != null || refreshToken.ExpiresAtUtc <= DateTime.UtcNow)
        {
            if (refreshToken.RevokedAtUtc != null && refreshToken.ReplacedByToken != null)
            {
                _logger.LogWarning("Attempted reuse of revoked refresh token for user {UserId}", refreshToken.UserId);
                await _refreshTokenService.RevokeAllUserRefreshTokensAsync(refreshToken.UserId, cancellationToken);
                await _context.SaveChangesAsync(cancellationToken);
            }
            throw new BusinessException("Nevažeći ili istekao refresh token.");
        }

        var user = await _context.UserAccounts
            .SingleOrDefaultAsync(x => x.Id == refreshToken.UserId && !x.IsDeleted, cancellationToken);

        if (user == null || !user.IsActive)
        {
            throw new BusinessException("Nevažeći korisnik za dati refresh token.");
        }

        var newRefreshToken = await _refreshTokenService.RotateRefreshTokenAsync(refreshToken.Token, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        var newAccessToken = _jwtTokenService.GenerateAccessToken(user);

        return new RefreshTokenResponse
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken.Token,
            RefreshTokenExpiresAtUtc = newRefreshToken.ExpiresAtUtc
        };
    }

    public async Task LogoutAsync(int userId, LogoutRequest request, CancellationToken cancellationToken = default)
    {
        var token = await _refreshTokenService.GetByTokenAsync(request.RefreshToken.Trim(), cancellationToken);

        if (token == null || token.UserId != userId)
        {
            throw new BusinessException("Nevažeći refresh token.");
        }

        await _refreshTokenService.RevokeRefreshTokenAsync(request.RefreshToken.Trim(), cancellationToken);
        await _tokenVersionService.InvalidateIssuedTokensAsync(userId, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken = default)
    {
        await _forgotPasswordValidator.ValidateAndThrowAsync(request, cancellationToken);

        var email = request.Email.Trim();
        var user = await _context.UserAccounts
            .SingleOrDefaultAsync(x => x.Email.ToLower() == email.ToLower() && !x.IsDeleted, cancellationToken);

        if (user == null || !user.IsActive)
        {
            _logger.LogWarning("Password reset requested for unknown or inactive e-mail address.");
            return;
        }

        var now = DateTime.UtcNow;

        await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);

        var activeTokens = await _context.PasswordResetTokens
            .Where(x => x.UserAccountId == user.Id && x.UsedAtUtc == null && x.ExpiresAtUtc > now)
            .ToListAsync(cancellationToken);

        foreach (var activeToken in activeTokens)
        {
            activeToken.ExpiresAtUtc = now;
            activeToken.UpdatedAtUtc = now;
        }

        var code = RandomNumberGenerator.GetInt32(100000, 1000000).ToString(CultureInfo.InvariantCulture);

        _context.PasswordResetTokens.Add(new PasswordResetToken
        {
            UserAccountId = user.Id,
            CodeHash = _cryptoService.HashPassword(code),
            ExpiresAtUtc = now.Add(PasswordResetCodeLifetime),
            CreatedAtUtc = now,
        });

        await _context.SaveChangesAsync(cancellationToken);

        try
        {
            await _emailNotificationPublisher.PublishOrThrowAsync(new EmailNotificationMessage
            {
                ToEmail = user.Email,
                ToName = $"{user.FirstName} {user.LastName}",
                Subject = "FitBook - kod za reset lozinke",
                Body = $"Poštovani {user.FirstName}, Vaš kod za reset lozinke je: {code}. Kod važi {(int)PasswordResetCodeLifetime.TotalMinutes} minuta. Ako niste zatražili reset lozinke, zanemarite ovu poruku.",
            }, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to queue the password reset code for user {UserId}. Previously issued codes remain valid.", user.Id);
            throw new BusinessException("Slanje koda za reset lozinke trenutno nije moguće. Pokušajte ponovo za nekoliko minuta.");
        }

        await transaction.CommitAsync(cancellationToken);

        _logger.LogInformation("Password reset code generated for user {UserId}.", user.Id);
    }

    public async Task ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken = default)
    {
        await _resetPasswordValidator.ValidateAndThrowAsync(request, cancellationToken);

        var email = request.Email.Trim();
        var user = await _context.UserAccounts
            .SingleOrDefaultAsync(x => x.Email.ToLower() == email.ToLower() && !x.IsDeleted, cancellationToken);

        if (user == null || !user.IsActive)
        {
            _logger.LogWarning("Password reset attempted for unknown or inactive e-mail address.");
            throw new BusinessException(InvalidResetCodeMessage);
        }

        var now = DateTime.UtcNow;

        var resetToken = await _context.PasswordResetTokens
            .Where(x => x.UserAccountId == user.Id && x.UsedAtUtc == null && x.ExpiresAtUtc > now)
            .OrderByDescending(x => x.CreatedAtUtc)
            .FirstOrDefaultAsync(cancellationToken);

        if (resetToken == null)
        {
            _logger.LogWarning("No active password reset code for user {UserId}.", user.Id);
            throw new BusinessException(InvalidResetCodeMessage);
        }

        if (!_cryptoService.VerifyPassword(request.Code.Trim(), resetToken.CodeHash))
        {
            resetToken.FailedAttempts++;
            resetToken.UpdatedAtUtc = now;

            if (resetToken.FailedAttempts >= MaxPasswordResetAttempts)
            {
                resetToken.ExpiresAtUtc = now;
                _logger.LogWarning(
                    "Password reset code for user {UserId} invalidated after {FailedAttempts} incorrect attempts.",
                    user.Id,
                    resetToken.FailedAttempts);
            }
            else
            {
                _logger.LogWarning(
                    "Incorrect password reset code for user {UserId} ({FailedAttempts}/{MaxAttempts}).",
                    user.Id,
                    resetToken.FailedAttempts,
                    MaxPasswordResetAttempts);
            }

            await _context.SaveChangesAsync(cancellationToken);

            throw new BusinessException(InvalidResetCodeMessage);
        }

        user.PasswordHash = _cryptoService.HashPassword(request.NewPassword.Trim());
        user.UpdatedAtUtc = now;

        resetToken.UsedAtUtc = now;
        resetToken.UpdatedAtUtc = now;

        var activeRefreshTokens = await _context.RefreshTokens
            .Where(x => x.UserId == user.Id && x.RevokedAtUtc == null)
            .ToListAsync(cancellationToken);

        foreach (var refreshToken in activeRefreshTokens)
        {
            refreshToken.RevokedAtUtc = now;
        }

        await _tokenVersionService.InvalidateIssuedTokensAsync(user.Id, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Password reset completed for user {UserId}.", user.Id);
    }
}
