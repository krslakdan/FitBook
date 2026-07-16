using FitBook.Model.Exceptions;
using FitBook.Model.Requests.Trainings;
using FitBook.Model.Responses.Trainings;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class TrainingService
    : BaseCRUDService<Training, TrainingResponse, TrainingSearchObject, TrainingInsertRequest, TrainingUpdateRequest>,
      ITrainingService
{
    public TrainingService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<TrainingInsertRequest> insertValidator,
        IValidator<TrainingUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<Training> ApplyFilter(IQueryable<Training> query, TrainingSearchObject search)
    {
        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        if (search.TrainingCategoryId.HasValue)
        {
            query = query.Where(x => x.TrainingCategoryId == search.TrainingCategoryId.Value);
        }

        if (search.DifficultyLevelId.HasValue)
        {
            query = query.Where(x => x.DifficultyLevelId == search.DifficultyLevelId.Value);
        }

        return query;
    }

    protected override IQueryable<Training> ApplySearch(IQueryable<Training> query, TrainingSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x =>
                x.Name.ToLower().Contains(term) ||
                x.Description.ToLower().Contains(term));
        }

        return query;
    }

    protected override async Task ValidateInsert(TrainingInsertRequest request, CancellationToken cancellationToken)
    {
        await ValidateForeignKeys(request.TrainingCategoryId, request.DifficultyLevelId, cancellationToken);
    }

    protected override async Task ValidateUpdate(int id, TrainingUpdateRequest request, Training entity, CancellationToken cancellationToken)
    {
        await ValidateForeignKeys(request.TrainingCategoryId, request.DifficultyLevelId, cancellationToken);
    }

    protected override async Task ValidateDelete(int id, Training entity, CancellationToken cancellationToken)
    {
        var hasTerms = await _dbContext.TrainingTerms
            .AnyAsync(t => t.TrainingId == id, cancellationToken);

        if (hasTerms)
        {
            throw new BusinessException($"Trening '{entity.Name}' ne može biti obrisan jer postoje termini treninga vezani za njega. Označite ga kao neaktivan umjesto brisanja.");
        }
    }

    private async Task ValidateForeignKeys(int categoryId, int difficultyLevelId, CancellationToken cancellationToken)
    {
        var categoryExists = await _dbContext.TrainingCategories
            .AnyAsync(c => c.Id == categoryId, cancellationToken);

        if (!categoryExists)
        {
            throw new NotFoundException($"Kategorija treninga sa ID {categoryId} nije pronađena.");
        }

        var difficultyExists = await _dbContext.DifficultyLevels
            .AnyAsync(d => d.Id == difficultyLevelId, cancellationToken);

        if (!difficultyExists)
        {
            throw new NotFoundException($"Nivo težine sa ID {difficultyLevelId} nije pronađen.");
        }
    }
}
