using FitBook.Common.Services.CryptoService;
using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
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

    private readonly ICryptoService _cryptoService;
    private readonly IValidator<UserAccountChangeOwnPasswordRequest> _changeOwnPasswordValidator;
    private readonly IValidator<UserAccountAdminPasswordResetRequest> _adminPasswordResetValidator;

    public UserAccountService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICryptoService cryptoService,
        IValidator<UserAccountInsertRequest> insertValidator,
        IValidator<UserAccountUpdateRequest> updateValidator,
        IValidator<UserAccountChangeOwnPasswordRequest> changeOwnPasswordValidator,
        IValidator<UserAccountAdminPasswordResetRequest> adminPasswordResetValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
        _cryptoService = cryptoService;
        _changeOwnPasswordValidator = changeOwnPasswordValidator;
        _adminPasswordResetValidator = adminPasswordResetValidator;
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
        await EnsureUniqueEmailAsync(request.Email, null, cancellationToken);
        await EnsureUniqueUsernameAsync(request.Username, null, cancellationToken);
    }

    protected override async Task ValidateUpdate(int id, UserAccountUpdateRequest request, UserAccount entity, CancellationToken cancellationToken)
    {
        if (!string.IsNullOrWhiteSpace(request.Email))
        {
            await EnsureUniqueEmailAsync(request.Email, id, cancellationToken);
        }

        if (!string.IsNullOrWhiteSpace(request.Username))
        {
            await EnsureUniqueUsernameAsync(request.Username, id, cancellationToken);
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
            throw new BusinessException("User account has active reservations and cannot be deleted.");
        }

        var hasActiveMembership = await _dbContext.UserMemberships
            .AnyAsync(
                membership => membership.UserAccountId == id &&
                              membership.IsActive &&
                              membership.Status == MembershipStatus.Active,
                cancellationToken);

        if (hasActiveMembership)
        {
            throw new BusinessException("User account has active membership and cannot be deleted.");
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

        var user = await _dbContext.UserAccounts
            .FirstOrDefaultAsync(x => x.Id == userId && !x.IsDeleted, cancellationToken);

        if (user is null)
        {
            throw new NotFoundException($"UserAccount with id {userId} was not found.");
        }

        if (!_cryptoService.VerifyPassword(request.CurrentPassword, user.PasswordHash))
        {
            throw new BusinessException("Current password is incorrect.");
        }

        user.PasswordHash = _cryptoService.HashPassword(request.NewPassword);
        user.UpdatedAtUtc = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);
        _logger.LogInformation("User {UserId} changed own password successfully.", userId);
    }

    public async Task AdminResetPasswordAsync(int userId, UserAccountAdminPasswordResetRequest request, CancellationToken cancellationToken = default)
    {
        await _adminPasswordResetValidator.ValidateAndThrowAsync(request, cancellationToken);

        var user = await _dbContext.UserAccounts
            .FirstOrDefaultAsync(x => x.Id == userId && !x.IsDeleted, cancellationToken);

        if (user is null)
        {
            throw new NotFoundException($"UserAccount with id {userId} was not found.");
        }

        user.PasswordHash = _cryptoService.HashPassword(request.NewPassword);
        user.UpdatedAtUtc = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);
        _logger.LogInformation("Admin reset password for user {UserId} successfully.", userId);
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
            throw new BusinessException("Email already exists.");
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
            throw new BusinessException("Username already exists.");
        }
    }
}
