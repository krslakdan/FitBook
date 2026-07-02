using FitBook.Common.Services.CryptoService;
using FitBook.Model.Exceptions;
using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace FitBook.Services;

public class UserAccountService
    : BaseCRUDService<UserAccount, UserAccountResponse, UserSearchObject, UserAccountInsertRequest, UserAccountUpdateRequest>,
      IUserAccountService
{
    private readonly ICryptoService _cryptoService;

    public UserAccountService(FitBookDbContext dbContext, IMapper mapper, ICryptoService cryptoService)
        : base(dbContext, mapper)
    {
        _cryptoService = cryptoService;
    }

    protected override IQueryable<UserAccount> AddFilter(IQueryable<UserAccount> query, UserSearchObject search)
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

        return query;
    }

    protected override IReadOnlyDictionary<string, string> BuildSortMappings()
    {
        return new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["id"] = nameof(UserAccount.Id),
            ["firstName"] = nameof(UserAccount.FirstName),
            ["lastName"] = nameof(UserAccount.LastName),
            ["email"] = nameof(UserAccount.Email),
            ["username"] = nameof(UserAccount.Username),
            ["role"] = nameof(UserAccount.Role),
            ["createdAtUtc"] = nameof(UserAccount.CreatedAtUtc)
        };
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

    protected override Task BeforeInsert(UserAccountInsertRequest request, UserAccount entity, CancellationToken cancellationToken)
    {
        entity.PasswordHash = _cryptoService.HashPassword(request.Password);
        entity.CreatedAtUtc = DateTime.UtcNow;
        entity.IsDeleted = false;
        return Task.CompletedTask;
    }

    protected override Task BeforeUpdate(int id, UserAccountUpdateRequest request, UserAccount entity, CancellationToken cancellationToken)
    {
        entity.UpdatedAtUtc = DateTime.UtcNow;

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            entity.PasswordHash = _cryptoService.HashPassword(request.Password);
        }

        return Task.CompletedTask;
    }

    protected override void MapUpdateToEntity(UserAccountUpdateRequest request, UserAccount entity)
    {
        request.Adapt(entity);
    }

    private async Task EnsureUniqueEmailAsync(string email, int? excludedUserId, CancellationToken cancellationToken)
    {
        var normalizedEmail = email.Trim().ToLowerInvariant();
        var exists = await DbContext.UserAccounts
            .AnyAsync(
                user => user.Email.ToLower() == normalizedEmail &&
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
        var exists = await DbContext.UserAccounts
            .AnyAsync(
                user => user.Username.ToLower() == normalizedUsername &&
                        (!excludedUserId.HasValue || user.Id != excludedUserId.Value),
                cancellationToken);

        if (exists)
        {
            throw new BusinessException("Username already exists.");
        }
    }
}
