using FitBook.Model.Exceptions;
using FitBook.Model.Requests.Halls;
using FitBook.Model.Responses.Halls;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class HallService
    : BaseCRUDService<Hall, HallResponse, HallSearchObject, HallInsertRequest, HallUpdateRequest>,
      IHallService
{
    public HallService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<HallInsertRequest> insertValidator,
        IValidator<HallUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<Hall> ApplyFilter(IQueryable<Hall> query, HallSearchObject search)
    {
        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<Hall> ApplySearch(IQueryable<Hall> query, HallSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x => x.Name.ToLower().Contains(term));
        }

        return query;
    }

    protected override Task ValidateInsert(HallInsertRequest request, CancellationToken cancellationToken)
        => EnsureNameIsUniqueAsync(request.Name, null, cancellationToken);

    protected override Task ValidateUpdate(int id, HallUpdateRequest request, Hall entity, CancellationToken cancellationToken)
        => EnsureNameIsUniqueAsync(request.Name, id, cancellationToken);

    protected override Task BeforeInsert(HallInsertRequest request, Hall entity, CancellationToken cancellationToken)
    {
        entity.Name = entity.Name.Trim();
        return Task.CompletedTask;
    }

    protected override Task BeforeUpdate(int id, HallUpdateRequest request, Hall entity, CancellationToken cancellationToken)
    {
        request.Name = request.Name.Trim();
        return Task.CompletedTask;
    }

    private async Task EnsureNameIsUniqueAsync(string name, int? excludeId, CancellationToken cancellationToken)
    {
        var normalized = name.Trim().ToLowerInvariant();
        var duplicateExists = await _dbContext.Halls
            .AnyAsync(x => x.Name.ToLower() == normalized && (excludeId == null || x.Id != excludeId.Value), cancellationToken);

        if (duplicateExists)
        {
            throw new BusinessException($"Sala sa nazivom '{name.Trim()}' već postoji.");
        }
    }

    protected override async Task ValidateDelete(int id, Hall entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.TrainingTerms
            .AnyAsync(x => x.HallId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException($"Sala '{entity.Name}' ne može biti obrisana jer postoje termini treninga koji je koriste. Označite je kao neaktivnu umjesto brisanja.");
        }
    }

    protected override string NotFoundMessage => "Sala nije pronađena.";
}
