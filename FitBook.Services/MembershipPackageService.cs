using FitBook.Model.Constants;
using FitBook.Model.Exceptions;
using FitBook.Model.Requests.MembershipPackages;
using FitBook.Model.Responses.MembershipPackages;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class MembershipPackageService
    : BaseCRUDService<MembershipPackage, MembershipPackageResponse, MembershipPackageSearchObject, MembershipPackageInsertRequest, MembershipPackageUpdateRequest>,
      IMembershipPackageService
{
    private readonly ICurrentUserService _currentUserService;

    public MembershipPackageService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICurrentUserService currentUserService,
        IValidator<MembershipPackageInsertRequest> insertValidator,
        IValidator<MembershipPackageUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
        _currentUserService = currentUserService;
    }

    protected override MembershipPackageSearchObject CreateDefaultSearch()
    {
        return new MembershipPackageSearchObject { IncludeInactive = true };
    }

    protected override IQueryable<MembershipPackage> ApplyFilter(IQueryable<MembershipPackage> query, MembershipPackageSearchObject search)
    {

        if (!_currentUserService.IsAdmin() || !search.IncludeDeleted)
        {
            query = query.Where(x => !x.IsDeleted);
        }


        if (!_currentUserService.IsAdmin())
        {
            query = query.Where(x => x.IsActive);
        }
        else if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }
        else if (!search.IncludeInactive)
        {

            query = query.Where(x => x.IsActive);
        }

        return query;
    }

    protected override IQueryable<MembershipPackage> ApplySearch(IQueryable<MembershipPackage> query, MembershipPackageSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x => x.Name.ToLower().Contains(term));
        }

        return query;
    }

    protected override Task ValidateInsert(MembershipPackageInsertRequest request, CancellationToken cancellationToken)
        => EnsureNameIsUniqueAsync(request.Name, null, cancellationToken);

    protected override Task ValidateUpdate(int id, MembershipPackageUpdateRequest request, MembershipPackage entity, CancellationToken cancellationToken)
        => EnsureNameIsUniqueAsync(request.Name, id, cancellationToken);

    protected override Task BeforeInsert(MembershipPackageInsertRequest request, MembershipPackage entity, CancellationToken cancellationToken)
    {
        entity.Name = entity.Name.Trim();
        return Task.CompletedTask;
    }

    protected override Task BeforeUpdate(int id, MembershipPackageUpdateRequest request, MembershipPackage entity, CancellationToken cancellationToken)
    {
        request.Name = request.Name.Trim();
        return Task.CompletedTask;
    }

    private async Task EnsureNameIsUniqueAsync(string name, int? excludeId, CancellationToken cancellationToken)
    {
        var normalized = name.Trim().ToLowerInvariant();
        var duplicateExists = await _dbContext.MembershipPackages
            .AnyAsync(x => !x.IsDeleted && x.Name.ToLower() == normalized && (excludeId == null || x.Id != excludeId.Value), cancellationToken);

        if (duplicateExists)
        {
            throw new BusinessException($"Paket članarine sa nazivom '{name.Trim()}' već postoji.");
        }
    }

    protected override async Task ValidateDelete(int id, MembershipPackage entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.UserMemberships
            .AnyAsync(x => x.MembershipPackageId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException("Paket se ne može obrisati jer postoje članarine vezane za njega. Ako više nije u upotrebi, označite ga kao neaktivan.");
        }
    }

    protected override string NotFoundMessage => "Paket članarine nije pronađen.";
}
