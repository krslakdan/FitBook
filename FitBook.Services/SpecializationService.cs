using FitBook.Model.Exceptions;
using FitBook.Model.Requests.Specializations;
using FitBook.Model.Responses.Specializations;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class SpecializationService
    : BaseCRUDService<Specialization, SpecializationResponse, SpecializationSearchObject, SpecializationInsertRequest, SpecializationUpdateRequest>,
      ISpecializationService
{
    public SpecializationService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<SpecializationInsertRequest> insertValidator,
        IValidator<SpecializationUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<Specialization> ApplyFilter(IQueryable<Specialization> query, SpecializationSearchObject search)
    {
        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<Specialization> ApplySearch(IQueryable<Specialization> query, SpecializationSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x => x.Name.ToLower().Contains(term));
        }

        return query;
    }

    protected override async Task ValidateInsert(SpecializationInsertRequest request, CancellationToken cancellationToken)
    {
        await EnsureNameIsUniqueAsync(request.Name, excludeId: null, cancellationToken);
    }

    protected override async Task ValidateUpdate(int id, SpecializationUpdateRequest request, Specialization entity, CancellationToken cancellationToken)
    {
        await EnsureNameIsUniqueAsync(request.Name, excludeId: id, cancellationToken);
    }

    protected override async Task ValidateDelete(int id, Specialization entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.Trainers
            .AnyAsync(x => x.SpecializationId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException($"Specijalizacija '{entity.Name}' ne može biti obrisana jer postoje treneri koji je koriste. Označite je kao neaktivnu umjesto brisanja.");
        }
    }

    private async Task EnsureNameIsUniqueAsync(string name, int? excludeId, CancellationToken cancellationToken)
    {
        var normalized = name.Trim().ToLowerInvariant();
        var duplicateExists = await _dbContext.Specializations
            .AnyAsync(x => x.Name.ToLower() == normalized && (excludeId == null || x.Id != excludeId.Value), cancellationToken);

        if (duplicateExists)
        {
            throw new BusinessException($"Specijalizacija sa nazivom '{name.Trim()}' već postoji.");
        }
    }
}
