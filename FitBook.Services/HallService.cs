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

    protected override async Task ValidateDelete(int id, Hall entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.TrainingTerms
            .AnyAsync(x => x.HallId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException($"Sala '{entity.Name}' ne može biti obrisana jer postoje termini treninga koji je koriste. Označite je kao neaktivnu umjesto brisanja.");
        }
    }
}
