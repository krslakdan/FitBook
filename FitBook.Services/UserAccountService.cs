using FitBook.Common.Services.CryptoService;
using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Model.Messages;
using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FitBook.Services.Interfaces.Auth;
using FitBook.Services.Messaging;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class UserAccountService
    : BaseCRUDService<UserAccount, UserAccountResponse, UserSearchObject, UserAccountInsertRequest, UserAccountUpdateRequest>,
      IUserAccountService
{
    private static readonly ReservationStatus[] ActiveReservationStatuses =
    [
        ReservationStatus.Pending,
        ReservationStatus.Confirmed
    ];

    private readonly IRefreshTokenService _refreshTokenService;
    private readonly ICryptoService _cryptoService;
    private readonly IValidator<UserAccountChangeOwnPasswordRequest> _changeOwnPasswordValidator;
    private readonly IValidator<UserAccountAdminPasswordResetRequest> _adminPasswordResetValidator;
    private readonly IEmailNotificationPublisher _emailNotificationPublisher;

    public UserAccountService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICryptoService cryptoService,
        IRefreshTokenService refreshTokenService,
        IValidator<UserAccountInsertRequest> insertValidator,
        IValidator<UserAccountUpdateRequest> updateValidator,
        IValidator<UserAccountChangeOwnPasswordRequest> changeOwnPasswordValidator,
        IValidator<UserAccountAdminPasswordResetRequest> adminPasswordResetValidator,
        IEmailNotificationPublisher emailNotificationPublisher)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
        _cryptoService = cryptoService;
        _refreshTokenService= refreshTokenService;
        _changeOwnPasswordValidator = changeOwnPasswordValidator;
        _adminPasswordResetValidator = adminPasswordResetValidator;
        _emailNotificationPublisher = emailNotificationPublisher;
    }

    protected override IQueryable<UserAccount> ApplyFilter(IQueryable<UserAccount> query, UserSearchObject search)
    {
        if (!search.IncludeDeleted)
        {
            query = query.Where(user => !user.IsDeleted);
        }

        if (!string.IsNullOrWhiteSpace(search.Role))
        {
            query = query.Where(user => user.Role == search.Role);
        }

        if (search.IsActive.HasValue)
        {
            query = query.Where(user => user.IsActive == search.IsActive.Value);
        }

        if (!string.IsNullOrWhiteSpace(search.Email))
        {
            var email = search.Email.Trim().ToLowerInvariant();
            query = query.Where(user => user.Email.ToLower().Contains(email));
        }

        if (!string.IsNullOrWhiteSpace(search.Username))
        {
            var username = search.Username.Trim().ToLowerInvariant();
            query = query.Where(user => user.Username.ToLower().Contains(username));
        }

        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            var name = search.Name.Trim().ToLowerInvariant();
            query = query.Where(user =>
                user.FirstName.ToLower().Contains(name) ||
                user.LastName.ToLower().Contains(name));
        }

        return query;
    }

    protected override IOrderedQueryable<UserAccount> ApplyOrdering(IQueryable<UserAccount> query, UserSearchObject search)
    {
        return query.OrderByDescending(user => user.CreatedAtUtc);
    }

    protected override IQueryable<UserAccount> ApplySearch(IQueryable<UserAccount> query, UserSearchObject search)
    {
        if (string.IsNullOrWhiteSpace(search.Search))
        {
            return query;
        }

        var term = search.Search.Trim().ToLowerInvariant();
        return query.Where(user =>
            user.Email.ToLower().Contains(term) ||
            user.Username.ToLower().Contains(term) ||
            user.FirstName.ToLower().Contains(term) ||
            user.LastName.ToLower().Contains(term));
    }

    protected override async Task ValidateInsert(UserAccountInsertRequest request, CancellationToken cancellationToken)
    {
        await EnsureUniqueEmailAsync(request.Email.Trim(), null, cancellationToken);
        await EnsureUniqueUsernameAsync(request.Username.Trim(), null, cancellationToken);
    }

    protected override async Task ValidateUpdate(int id, UserAccountUpdateRequest request, UserAccount entity, CancellationToken cancellationToken)
    {
        if (!string.IsNullOrWhiteSpace(request.Email))
        {
            await EnsureUniqueEmailAsync(request.Email.Trim(), id, cancellationToken);
        }

        if (!string.IsNullOrWhiteSpace(request.Username))
        {
            await EnsureUniqueUsernameAsync(request.Username.Trim(), id, cancellationToken);
        }
    }

    protected override async Task ValidateDelete(int id, UserAccount entity, CancellationToken cancellationToken)
    {
        var hasActiveReservations = await _dbContext.Reservations
            .AnyAsync(
                reservation => reservation.UserAccountId == id &&
                               ActiveReservationStatuses.Contains(reservation.Status),
                cancellationToken);

        if (hasActiveReservations)
        {
            throw new BusinessException("Korisnički račun ima aktivne rezervacije i ne može biti obrisan.");
        }

        var hasActiveMembership = await _dbContext.UserMemberships
            .AnyAsync(
                membership => membership.UserAccountId == id &&
                              membership.IsActive &&
                              membership.Status == MembershipStatus.Active,
                cancellationToken);

        if (hasActiveMembership)
        {
            throw new BusinessException("Korisnički račun ima aktivnu članarinu i ne može biti obrisan.");
        }

        var isTrainer = await _dbContext.Trainers
            .AnyAsync(t => t.UserAccountId == id && t.IsActive, cancellationToken);

        if (isTrainer)
        {
            throw new BusinessException("Korisnički račun je povezan sa aktivnim trenerskim profilom i ne može biti obrisan.");
        }
    }

    protected override Task BeforeInsert(UserAccountInsertRequest request, UserAccount entity, CancellationToken cancellationToken)
    {
        entity.PasswordHash = _cryptoService.HashPassword(request.Password);
        return Task.CompletedTask;
    }

    public async Task ChangeOwnPasswordAsync(int userId, UserAccountChangeOwnPasswordRequest request, CancellationToken cancellationToken = default)
    {
        await _changeOwnPasswordValidator.ValidateAndThrowAsync(request, cancellationToken);

        var user = await GetUserForPasswordChangeAsync(userId, cancellationToken);

        if (!_cryptoService.VerifyPassword(request.CurrentPassword, user.PasswordHash))
        {
            throw new BusinessException("Trenutna lozinka nije ispravna.");
        }

        await SetPasswordAndRevokeTokensAsync(user, request.NewPassword, cancellationToken);
        _logger.LogInformation("User {UserId} changed own password successfully.", userId);
    }

    public async Task AdminResetPasswordAsync(int userId, UserAccountAdminPasswordResetRequest request, CancellationToken cancellationToken = default)
    {
        await _adminPasswordResetValidator.ValidateAndThrowAsync(request, cancellationToken);

        var user = await GetUserForPasswordChangeAsync(userId, cancellationToken);

        await SetPasswordAndRevokeTokensAsync(user, request.NewPassword, cancellationToken);
        _logger.LogInformation("Admin reset password for user {UserId} successfully.", userId);

        await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
        {
            ToEmail = user.Email,
            ToName = $"{user.FirstName} {user.LastName}",
            Subject = "Vaša lozinka je promijenjena",
            Body = $"Poštovani {user.FirstName}, Vaša lozinka za FitBook nalog je upravo promijenjena od strane administratora. Ako niste vi zatražili ovu izmjenu, odmah kontaktirajte podršku.",
        }, cancellationToken);
    }

    private async Task<UserAccount> GetUserForPasswordChangeAsync(int userId, CancellationToken cancellationToken)
    {
        var user = await _dbContext.UserAccounts
            .FirstOrDefaultAsync(x => x.Id == userId && !x.IsDeleted, cancellationToken);

        if (user is null)
        {
            throw new NotFoundException($"Korisnički račun sa ID {userId} nije pronađen.");
        }

        return user;
    }

    private async Task SetPasswordAndRevokeTokensAsync(UserAccount user, string newPassword, CancellationToken cancellationToken)
    {
        await using var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken);

        user.PasswordHash = _cryptoService.HashPassword(newPassword);
        user.UpdatedAtUtc = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);
        await _refreshTokenService.RevokeAllUserRefreshTokensAsync(user.Id, cancellationToken);

        await transaction.CommitAsync(cancellationToken);
    }

    private async Task EnsureUniqueEmailAsync(string email, int? excludedUserId, CancellationToken cancellationToken)
    {
        var normalizedEmail = email.Trim().ToLowerInvariant();
        var exists = await _dbContext.UserAccounts
            .AnyAsync(
                user => !user.IsDeleted &&
                        user.Email.ToLower() == normalizedEmail &&
                        (!excludedUserId.HasValue || user.Id != excludedUserId.Value),
                cancellationToken);

        if (exists)
        {
            throw new BusinessException("Email adresa već postoji.");
        }
    }

    private async Task EnsureUniqueUsernameAsync(string username, int? excludedUserId, CancellationToken cancellationToken)
    {
        var normalizedUsername = username.Trim().ToLowerInvariant();
        var exists = await _dbContext.UserAccounts
            .AnyAsync(
                user => !user.IsDeleted &&
                        user.Username.ToLower() == normalizedUsername &&
                        (!excludedUserId.HasValue || user.Id != excludedUserId.Value),
                cancellationToken);

        if (exists)
        {
            throw new BusinessException("Korisničko ime već postoji.");
        }
    }
}
