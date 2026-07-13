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

    protected override async Task ValidateDelete(int id, MembershipPackage entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.UserMemberships
            .AnyAsync(x => x.MembershipPackageId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException("Paket se ne može obrisati jer postoje članarine vezane za njega. Ako više nije u upotrebi, označite ga kao neaktivan.");
        }
    }
}
