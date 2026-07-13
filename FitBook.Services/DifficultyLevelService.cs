using FitBook.Model.Exceptions;
using FitBook.Model.Requests.DifficultyLevels;
using FitBook.Model.Responses.DifficultyLevels;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class DifficultyLevelService
    : BaseCRUDService<DifficultyLevel, DifficultyLevelResponse, DifficultyLevelSearchObject, DifficultyLevelInsertRequest, DifficultyLevelUpdateRequest>,
      IDifficultyLevelService
{
    public DifficultyLevelService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<DifficultyLevelInsertRequest> insertValidator,
        IValidator<DifficultyLevelUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<DifficultyLevel> ApplyFilter(IQueryable<DifficultyLevel> query, DifficultyLevelSearchObject search)
    {
        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<DifficultyLevel> ApplySearch(IQueryable<DifficultyLevel> query, DifficultyLevelSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x => x.Name.ToLower().Contains(term));
        }

        return query;
    }

    protected override async Task ValidateDelete(int id, DifficultyLevel entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.Trainings
            .AnyAsync(x => x.DifficultyLevelId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException($"Nivo težine '{entity.Name}' ne može biti obrisan jer postoje treninzi koji ga koriste. Označite ga kao neaktivan umjesto brisanja.");
        }
    }
}
